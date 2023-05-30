describe Smoketests::SmoketestCleanup do
  before do
    Session.truncate
  end
  before :each do
    10.times { Session.create(siteIP: "1.2.3.4") }
    10.times { Session.create(siteIP: "2.3.4.5") }
  end
  it "deletes all sessions" do
    ENV["SMOKE_TEST_IPS"] = "1.2.3.4,2.3.4.5"
    expect { Smoketests::SmoketestCleanup.new.clean }.to change { Session.count }.from(20).to(0)
  end
  it "ignores sessions from other IPs" do
    ENV["SMOKE_TEST_IPS"] = "1.2.3.4"
    expect { Smoketests::SmoketestCleanup.new.clean }.to change { Session.count }.from(20).to(10)
    expect(Session.where(siteIP: "2.3.4.5").count).to eq(10)
  end
  it "ignores whitespace in the list of IPs" do
    ENV["SMOKE_TEST_IPS"] = "  1.2.3.4  ,   2.3.4.5   "
    expect { Smoketests::SmoketestCleanup.new.clean }.to change { Session.count }.from(20).to(0)
  end
  it "reports the number of rows deleted" do
    ENV["SMOKE_TEST_IPS"] = "1.2.3.4"
    expect { Smoketests::SmoketestCleanup.new.clean }.to output(/10 rows affected/).to_stdout
  end
end
