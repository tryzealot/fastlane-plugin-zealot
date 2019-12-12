describe Fastlane::Actions::ZealotAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The zealot plugin is working!")

      Fastlane::Actions::ZealotAction.run(nil)
    end
  end
end
