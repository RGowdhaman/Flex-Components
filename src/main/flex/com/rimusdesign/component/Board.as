package com.rimusdesign.component {


	import com.rimusdesign.component.skin.BoardSkin;
	import mx.collections.IList;
	import spark.components.DataGroup;
	import spark.components.supportClasses.SkinnableComponent;


	public class Board extends SkinnableComponent {


		[SkinPart(required="true")]
		public var messagesDataGrid : DataGroup;
		
		[Bindable]
		public var dataProvider : IList;


		public function Board () {
			super ();
			setStyle ( "skinClass", BoardSkin );
		}


		override protected function partAdded ( partName : String, instance : Object ) : void {
			super.partAdded ( partName, instance );
		}
	}
}