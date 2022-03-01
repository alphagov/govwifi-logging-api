describe Gdpr::UseCase::SessionDeletion do
  subject do
    described_class.new(
      session_gateway:,
    )
  end

  let(:session_gateway) { double(delete_sessions: nil) }

  context "Given a session gateway" do
    it "calls delete_sessions on the gateway" do
      subject.execute
      expect(session_gateway).to have_received(:delete_sessions)
    end
  end
end
