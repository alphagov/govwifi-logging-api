describe Gdpr::Gateway::Session do
  let(:session) { DB[:sessions] }
  before { session.delete }

  context "Given some sessions are older than 32 days" do
    before do
      session.insert(start: Date.today, username: "bob")
      session.insert(start: Date.today, username: "sally")
      session.insert(start: Date.today - 33, username: "george")
    end

    it "deletes the old sessions" do
      subject.delete_sessions
      expect(session.all.map { |s| s.fetch(:username) }).to eq(%w(bob sally))
    end
  end

  context "Given all sessions are recent" do
    before do
      session.insert(start: Date.today, username: "sally")
      session.insert(start: Date.today, username: "george")
    end

    it "does not delete the sessions" do
      subject.delete_sessions
      expect(session.all.map { |s| s.fetch(:username) }).to eq(%w(sally george))
    end
  end

  context "Given all sessions are old" do
    before do
      session.insert(start: Date.today - 33, username: "Adam")
      session.insert(start: Date.today - 33, username: "Betty")
    end

    it "deletes the sessions" do
      subject.delete_sessions
      expect(session.all.map { |s| s.fetch(:username) }).to be_empty
    end
  end
end
