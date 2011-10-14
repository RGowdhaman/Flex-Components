package com.rimusdesign.component.layout {


	import spark.components.supportClasses.ItemRenderer;
	import spark.layouts.supportClasses.LayoutBase;
	import mx.core.ILayoutElement;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.states.State;
	import flash.events.TimerEvent;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Timer;


	public class CoverflowLayout extends LayoutBase {


		private static const ANIMATION_DURATION : int = 600;
		private static const ANIMATION_STEPS : int = 32;
		// fps
		private static const ROTATION : Number = 64;
		private static const FOCAL_LENGTH : Number = 800;
		private static const DEPTH_DISTANCE : Number = 32;
		
		private var finalMatrices : Vector.<Matrix3D>;
		private var centerX : Number;
		private var centerY : Number;
		private var transitionTimer : Timer;
		private var _selectedIndex : int;
		private var _centerOffset : Number = 180;
		private var _spacing : Number = 180;


		public function set selectedIndex ( value : int ) : void {
			_selectedIndex = value;
			invalidateTarget ();
		}
		
		
		public function get selectedIndex ( ) : int {
			return _selectedIndex;
		}
		
		
		public function get centerOffset () : Number {
			return _centerOffset;
		}


		public function set centerOffset ( centerOffset : Number ) : void {
			_centerOffset = centerOffset;
			invalidateTarget ();
		}
		
		
		public function get spacing () : Number {
			return _spacing;
		}


		public function set spacing ( spacing : Number ) : void {
			_spacing = spacing;
			invalidateTarget ();
		}


		private function invalidateTarget () : void {
			if (target) {
				target.invalidateDisplayList ();
				target.invalidateSize ();
			}
		}


		private function centerPerspectiveProjection ( width : Number, height : Number ) : void {
			var perspectiveProjection : PerspectiveProjection = new PerspectiveProjection ();
			perspectiveProjection.projectionCenter = new Point ( width / 2, height / 2 );
			perspectiveProjection.focalLength = FOCAL_LENGTH;

			target.transform.perspectiveProjection = perspectiveProjection;
		}


		override public function updateDisplayList ( width : Number, height : Number ) : void {
			centerX = width / 2;
			centerY = height / 2;

			if ( target.numElements > 0) {
				centerPerspectiveProjection ( width, height );

				finalMatrices = new Vector.<Matrix3D> ();
				
				var selectedIndexMatrix : Matrix3D = positionSelectedElement ( target.getVirtualElementAt ( selectedIndex ) );
				
				for ( var i : int = 0; i < target.numElements; i++ ) {
					
					var element : ILayoutElement = target.getVirtualElementAt ( i );

					if ( i == selectedIndex ) {
						finalMatrices.push ( selectedIndexMatrix );
						( element as IVisualElement ).depth = target.numElements - 1;
					} else if ( i < selectedIndex ) {
						finalMatrices.push ( positionElementLeft ( element, i ) );
						( element as IVisualElement ).depth = i;
					} else {
						finalMatrices.push ( positionElementRight ( element, i ) );
						( element as IVisualElement ).depth = ( ( target.numElements - 1 ) - selectedIndex ) - i;
					}
				}

				playTransition ();
				
			}
		}


		private function positionSelectedElement ( element : ILayoutElement ) : Matrix3D {
			
			element.setLayoutBoundsSize ( NaN, NaN, false );
			var matrix : Matrix3D = new Matrix3D ( );
			
			var elementWidth : Number = element.getLayoutBoundsWidth ( false );
			var elementHeight : Number = element.getLayoutBoundsHeight ( false );
			
			matrix.appendTranslation ( Math.round ( centerX - (elementWidth * 0.5) ), Math.round ( centerY - (elementHeight * 0.5) ), 0 );

			element.setLayoutBoundsSize ( NaN, NaN, false );
			
			setState ( element, "selected" );

			return matrix;
		}


		private function positionElementLeft ( element : ILayoutElement, index : int ) : Matrix3D {
			
			element.setLayoutBoundsSize ( NaN, NaN, false );
			
			var matrix : Matrix3D = new Matrix3D ();
			
			var elementWidth : Number = element.getLayoutBoundsWidth ( false );
			var elementHeight : Number = element.getLayoutBoundsHeight ( false );

			matrix.appendRotation ( -ROTATION, Vector3D.Y_AXIS );
			
			index = selectedIndex - index;
			
			matrix.appendTranslation ( Math.round ( ( centerX - centerOffset ) - ( index * elementWidth ) ), Math.round ( centerY - (elementHeight * 0.5) ), index * DEPTH_DISTANCE );
			
			matrix.appendTranslation ( spacing * index , 0, 0 );
			
			setState ( element, "normal" );
			
			return matrix;
		}


		private function positionElementRight ( element : ILayoutElement, index : int ) : Matrix3D {
			
			element.setLayoutBoundsSize ( NaN, NaN, false );
			
			var matrix : Matrix3D = new Matrix3D ();
			
			var elementWidth : Number = element.getLayoutBoundsWidth ( false );
			var elementHeight : Number = element.getLayoutBoundsHeight ( false );

			matrix.appendTranslation ( -elementWidth, 0, 0 );
			matrix.appendRotation ( ROTATION, Vector3D.Y_AXIS );
			matrix.appendTranslation ( elementWidth, 0, 0 );
			
			index = index - selectedIndex;
			
			matrix.appendTranslation ( Math.round ( ( centerX + centerOffset ) + ( ( index - 1 ) * elementWidth ) ), Math.round ( centerY - (elementHeight * 0.5) ), index * DEPTH_DISTANCE );
			
			matrix.appendTranslation ( -spacing * index , 0, 0 );
			
			setState ( element, "normal" );
			
			return matrix;
		}
		
		
		private function setState ( element : ILayoutElement, stateName : String ) : void {
			
			if ( element is ItemRenderer ) {
				
				var hasState : Boolean;
				
				for each ( var state : State in ( element as ItemRenderer ).states ) {
					if ( state.name == stateName ) {
						hasState = true;
						break;
					}
				}
				
				if ( hasState ) ( element as ItemRenderer ).currentState = stateName;
			}
			
		}


		// SCROLLING TRANSITION
		private function playTransition () : void {
			if (transitionTimer) {
				transitionTimer.stop ();
				transitionTimer.reset ();
			} else {
				transitionTimer = new Timer ( ANIMATION_DURATION / ANIMATION_STEPS, ANIMATION_STEPS );
				transitionTimer.addEventListener ( TimerEvent.TIMER, animationTickHandler );
				transitionTimer.addEventListener ( TimerEvent.TIMER_COMPLETE, animationTimerCompleteHandler );
			}

			transitionTimer.start ();
		}


		private function animationTickHandler ( event : TimerEvent ) : void {
			var numElements : int = target.numElements;

			var initialMatrix : Matrix3D;
			var finalMatrix : Matrix3D;
			var element : ILayoutElement;

			for (var i : int = 0; i < numElements; i++) {
				finalMatrix = finalMatrices[i];

				element = target.getVirtualElementAt ( i );

				initialMatrix = UIComponent ( element ).transform.matrix3D;
				initialMatrix.interpolateTo ( finalMatrix, 0.2 );
				element.setLayoutMatrix3D ( initialMatrix, false );
			}
		}


		private function animationTimerCompleteHandler ( event : TimerEvent ) : void {
			finalMatrices = null;
		}


	}
}