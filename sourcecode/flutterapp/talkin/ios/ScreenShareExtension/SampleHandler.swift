import ReplayKit
import ZegoExpressEngine

class SampleHandler: RPBroadcastSampleHandler, ZegoReplayKitExtHandler {

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        ZegoReplayKitExt.sharedInstance().setup(withDelegate: self, appGroup: "group.com.notisboard.mobile.screenshare")
    }

    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }

    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }

    override func broadcastFinished() {
        // Broadcast has finished.
        ZegoReplayKitExt.sharedInstance().finished()
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        ZegoReplayKitExt.sharedInstance().send(sampleBuffer, with: sampleBufferType)
    }
}
