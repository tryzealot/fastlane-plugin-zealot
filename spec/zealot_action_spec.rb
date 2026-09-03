describe Fastlane::Actions::ZealotAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The zealot plugin is working!")

      Fastlane::Actions::ZealotAction.run(nil)
    end
  end

  describe Fastlane::Helper::ZealotHelper do
    it 'builds multipart file parts with current Faraday' do
      helper = Object.new.extend(Fastlane::Helper::ZealotHelper)
      file = Tempfile.new('zealot-upload')
      params = {
        token: 'token',
        channel_key: 'channel',
        release_version: '1.0.0',
        build_version: '1'
      }

      upload = helper.upload_debug_file_params(params, file.path)[:file]

      expect(upload).to be_a(Faraday::Multipart::FilePart)
      expect(upload.path).to eq(file.path)
      expect(upload.content_type).to eq('application/octet-stream')
    ensure
      file&.close!
    end
  end
end
