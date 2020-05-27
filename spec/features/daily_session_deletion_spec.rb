describe "daily session deletion" do
  subject { Gdpr::UseCase::SessionDeletion.new(session_gateway: Gdpr::Gateway::Session.new) }
  let(:session) { DB[:sessions] }

  context "Given sessions older than 3 months" do
    before do
      session.delete
      session.insert(start: Date.today, username: "bob")
      session.insert(start: Date.today, username: "sally")
      session.insert(start: Date.today - 120, username: "george")
    end

    it "deletes the session" do
      subject.execute
      expect(session.all.map { |s| s.fetch(:username) }).to eq(%w[bob sally])
    end
  end
end
