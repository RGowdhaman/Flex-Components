package com.rimusdesign.component {


	import com.rimusdesign.component.skin.CommentBoxSkin;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import spark.components.Button;
	import spark.components.TextArea;
	import spark.components.supportClasses.SkinnableComponent;



	[Event(name="send", type="flash.events.Event")]
	public class CommentBox extends SkinnableComponent {


		[SkinPart(required="true")]
		public var messageTextArea	: TextArea;
		
		[SkinPart(required="true")]
		public var btnSend			: Button;
		
		
		public var message			: String = "";


		public function CommentBox ( ) {
			
			super ( );
			setStyle ( "skinClass", CommentBoxSkin );
		}


		override protected function partAdded ( partName : String, instance : Object ) : void {
			
			super.partAdded ( partName, instance );

			if (instance == btnSend) {
				btnSend.addEventListener ( MouseEvent.CLICK, sendHandler );
			}
		}


		protected function sendHandler ( event : MouseEvent ) : void {
			
			message					= messageTextArea.text;
			messageTextArea.text	= "";
			dispatchEvent ( new Event ( "send" ) );
		}
		
		
	}
}