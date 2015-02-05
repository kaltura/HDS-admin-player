package
{
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.external.ExternalInterface;
	
	import org.osmf.display.ScaleMode;
	import org.osmf.elements.F4MElement;
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingURLResource;
	
	public class Player extends Sprite
	{
		private var manifestElement:MediaElement;
		private var manifestPlaying:Boolean;
		private var onSyncPoint:String;
		
		public function Player()
		{
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var url:String = stage.loaderInfo.parameters.url;
			onSyncPoint = stage.loaderInfo.parameters.onSyncPoint;
			var playerWidth:Number = isNaN( stage.loaderInfo.parameters.width ) ? 400 : stage.loaderInfo.parameters.width ;
			var playerHeight:Number = isNaN( stage.loaderInfo.parameters.height ) ? 333 : stage.loaderInfo.parameters.height ;

			var mediaPlayerSprite:MediaPlayerSprite = new MediaPlayerSprite();
			addChild(mediaPlayerSprite);
		
			var resource:StreamingURLResource = new StreamingURLResource(url, StreamType.LIVE_OR_RECORDED );
			manifestElement = new F4MElement( resource );
			
			mediaPlayerSprite.x = 0;
			mediaPlayerSprite.y = 0;

			mediaPlayerSprite.width = playerWidth;
			mediaPlayerSprite.height = playerHeight;

			mediaPlayerSprite.mediaPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onPlayerStateChange);
			mediaPlayerSprite.mediaPlayer.media = manifestElement;
		}
		
		public function onPlayerStateChange( event:MediaPlayerStateChangeEvent ) : void
		{
			switch(event.state)
			{
				case "buffering":
				case "playing":
					if(!manifestPlaying)
					{
						manifestPlaying = true;
						trace("Playing");
						
						var media:Object = manifestElement;
						while (media is ProxyElement)
						{
							media = (media as ProxyElement).proxiedElement;
						} 
						if (media.hasOwnProperty("client") && media["client"]) {
							media["client"].addHandler( "onMetaData", onMetaData );
						}
					}
					break;
				
				case "loading":
					trace("Loading player");
					manifestPlaying = false;
					break;
				
				case "playbackError":
					trace("Player error");
					break;
				
				default:
					trace("Unhandled player state: " + event.state);
			}
		}
		
		public function onMetaData( metadata : Object ) : void
		{
			if(metadata.hasOwnProperty("objectType") && metadata.objectType == "KalturaSyncPoint")
			{
				trace("onSyncPoint [" + onSyncPoint + "]");
				ExternalInterface.call(onSyncPoint, metadata);
			}
		}
	}
}