describe MacFormatter do
  it "preserves a correctly formatted MAC" do
    mac = "50-A6-7F-84-9C-D1"
    result = subject.execute(mac:)
    expect(result).to eq("50-A6-7F-84-9C-D1")
  end

  it "ensures that a MAC is all capital letters" do
    mac = "50-a6-7f-84-9c-d1"
    result = subject.execute(mac:)
    expect(result).to eq("50-A6-7F-84-9C-D1")
  end

  it "ensures all characters are separated by dashes" do
    mac = "50A67F849CD1"
    result = subject.execute(mac:)
    expect(result).to eq("50-A6-7F-84-9C-D1")
  end

  it "ensures the rest of the characters are separated by dashes" do
    mac = "50-A67F849CD1"
    result = subject.execute(mac:)
    expect(result).to eq("50-A6-7F-84-9C-D1")
  end

  it "trims off excess characters" do
    mac = "50A67F849CD1FF"
    result = subject.execute(mac:)
    expect(result).to eq("50-A6-7F-84-9C-D1")
  end

  it "not enough characters" do
    mac = "fff333"
    result = subject.execute(mac:)
    expect(result).to eq("FF-F3-33---")
  end

  it "no valid characters" do
    mac = "gggiiijjj"
    result = subject.execute(mac:)
    expect(result).to eq("-----")
  end

  it "formats a mac with a nil value" do
    mac = nil
    result = subject.execute(mac:)
    expect(result).to eq("-----")
  end

  it "some valid characters" do
    mac = "fffiiijjj"
    result = subject.execute(mac:)
    expect(result).to eq("FF-F----")
  end

  it "Throws an error when no MAC argument is supplied" do
    expect { subject.execute }.to raise_error(ArgumentError)
  end
end
