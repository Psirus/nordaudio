import unittest
import nordaudio

test "Scaffold":
  var outputParameters: StreamParameters
  discard initialize()
  outputParameters.device = getDefaultOutputDevice()
  outputParameters.channelCount = 2
  outputParameters.sampleFormat = paFloat32
  outputParameters.suggestedLatency = getDeviceInfo(outputParameters.device).defaultLowOutputLatency
  outputParameters.hostApiSpecificStreamInfo = nil
  terminate()
