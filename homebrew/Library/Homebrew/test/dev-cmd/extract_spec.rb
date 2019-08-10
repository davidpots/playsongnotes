# frozen_string_literal: true

require "cmd/shared_examples/args_parse"

describe "Homebrew.extract_args" do
  it_behaves_like "parseable arguments"
end

describe "brew extract", :integration_test do
  it "retrieves the specified version of formula, defaulting to most recent" do
    path = Tap::TAP_DIRECTORY/"homebrew/homebrew-foo"
    (path/"Formula").mkpath
    target = Tap.from_path(path)
    core_tap = CoreTap.new
    core_tap.path.cd do
      system "git", "init"
      formula_file = setup_test_formula "testball"
      system "git", "add", "--all"
      system "git", "commit", "-m", "testball 0.1"
      contents = File.read(formula_file)
      contents.gsub!("testball-0.1", "testball-0.2")
      File.write(formula_file, contents)
      system "git", "add", "--all"
      system "git", "commit", "-m", "testball 0.2"
    end

    expect { brew "extract", "testball", target.name, "--version=0.1" }
      .to be_a_success

    expect(path/"Formula/testball@0.1.rb").to exist

    expect(Formulary.factory(path/"Formula/testball@0.1.rb").version).to be == "0.1"
  end
end
