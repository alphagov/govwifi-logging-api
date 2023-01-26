describe Smoketests::SmoketestCleanup do
  before do
    User.truncate
    Session.truncate
  end

  context "Deleting smoke test users" do
    context "Given no test users" do
      before do
        User.insert(username: "foo", contact: "foo@example.com", created_at: Date.today - 1)
        User.insert(username: "bar", contact: "bar@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
      end

      it "does not delete any users" do
        expect { subject.clean }.not_to(change { User.count })
      end

      it "does not delete any sessions" do
        expect { subject.clean }.not_to(change { Session.count })
      end
    end

    context "Given one test user" do
      before do
        User.insert(username: "foo", contact: "foo@example.com", created_at: Date.today - 1)
        User.insert(username: "bar", contact: "bar@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
        User.insert(username: "baz", contact: "govwifi-tests+baz@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
        Session.insert(username: "foo")
        Session.insert(username: "bar")
        Session.insert(username: "baz")
      end

      it "deletes only the old test user record" do
        subject.clean
        expect(User.select_map(:username)).to match_array(%w[foo bar])
      end

      it "deletes only associated sessions" do
        subject.clean
        expect(Session.select_map(:username)).to match_array(%w[foo bar])
      end
    end

    context "Given multiple test users" do
      before do
        User.insert(username: "foo", contact: "govwifi-tests+foo@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
        User.insert(username: "bar", contact: "govwifi-tests+bar@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
        User.insert(username: "baz", contact: "govwifi-tests+baz@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
        Session.insert(username: "foo")
        Session.insert(username: "bar")
        Session.insert(username: "baz")
      end

      it "deletes all the test users" do
        expect { subject.clean }.to change { User.count }.from(3).to(0)
      end
      it "deletes all test sessions" do
        expect { subject.clean }.to change { Session.count }.from(3).to(0)
      end
    end

    context "Given a recently created test user" do
      before do
        User.insert(username: "foo", contact: "govwifi-tests+foo@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
        User.insert(username: "bar", contact: "govwifi-tests+bar@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
        User.insert(username: "baz", contact: "govwifi-tests+baz@digital.cabinet-office.gov.uk")
        Session.insert(username: "foo")
        Session.insert(username: "bar")
        Session.insert(username: "baz")
      end

      it "does not delete the recent test user" do
        subject.clean
        expect(User.select_map(:username)).to include("baz")
      end
    end
    context "More sessions and username than the batch size" do
      let(:number) { (Smoketests::SmoketestCleanup::SESSION_BATCH_SIZE * 2.5).round }
      before :each do
        username = "aaaaaa"
        number.times do
          username = username.next
          User.insert(username:, contact: "govwifi-tests+baz@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
          2.times { Session.insert(username:) }
        end
      end
      it "deletes all the test users" do
        expect { subject.clean }.to change { User.count }.from(number).to(0)
      end
      it "deletes all test sessions" do
        expect { subject.clean }.to change { Session.count }.from(number * 2).to(0)
      end
    end
  end
end
