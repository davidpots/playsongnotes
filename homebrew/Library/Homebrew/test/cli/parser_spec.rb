# frozen_string_literal: true

require_relative "../../cli/parser"

describe Homebrew::CLI::Parser do
  describe "test switch options" do
    subject(:parser) {
      described_class.new do
        switch :verbose, description: "Flag for verbosity"
        switch "--more-verbose", description: "Flag for higher verbosity"
        switch "--pry", env: :pry
      end
    }

    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("HOMEBREW_PRY").and_return("1")
    end

    it "parses short option" do
      parser.parse(["-v"])
      expect(Homebrew.args).to be_verbose
    end

    it "parses a single valid option" do
      parser.parse(["--verbose"])
      expect(Homebrew.args).to be_verbose
    end

    it "parses a valid option along with few unnamed args" do
      args = %w[--verbose unnamed args]
      parser.parse(args)
      expect(Homebrew.args).to be_verbose
      expect(args).to eq %w[--verbose unnamed args]
    end

    it "parses a single option and checks other options to be nil" do
      parser.parse(["--verbose"])
      expect(Homebrew.args).to be_verbose
      expect(Homebrew.args.more_verbose?).to be nil
    end

    it "raises an exception and outputs help text when an invalid option is passed" do
      expect { parser.parse(["--random"]) }.to raise_error(OptionParser::InvalidOption, /--random/)
                                           .and output(/Usage: brew/).to_stderr
    end

    it "maps environment var to an option" do
      parser.parse([])
      expect(Homebrew.args.pry?).to be true
    end

    it ":verbose with custom description" do
      _, _, _, desc = parser.processed_options.find { |short, _| short == "-v" }
      expect(desc).to eq "Flag for verbosity"
    end
  end

  describe "test long flag options" do
    subject(:parser) {
      described_class.new do
        flag        "--filename=", description: "Name of the file"
        comma_array "--files",     description: "Comma separated filenames"
      end
    }

    it "parses a long flag option with its argument" do
      parser.parse(["--filename=random.txt"])
      expect(Homebrew.args.filename).to eq "random.txt"
    end

    it "raises an exception when a flag's required value is not passed" do
      expect { parser.parse(["--filename"]) }.to raise_error(OptionParser::MissingArgument, /--filename/)
    end

    it "parses a comma array flag option" do
      parser.parse(["--files=random1.txt,random2.txt"])
      expect(Homebrew.args.files).to eq %w[random1.txt random2.txt]
    end
  end

  describe "test short flag options" do
    subject(:parser) {
      described_class.new do
        flag "-f", "--filename=", description: "Name of the file"
      end
    }

    it "parses a short flag option with its argument" do
      parser.parse(["--filename=random.txt"])
      expect(Homebrew.args.filename).to eq "random.txt"
      expect(Homebrew.args.f).to eq "random.txt"
    end
  end

  describe "test constraints for flag options" do
    subject(:parser) {
      described_class.new do
        flag      "--flag1="
        flag      "--flag3="
        flag      "--flag2=", required_for: "--flag1="
        flag      "--flag4=", depends_on: "--flag3="

        conflicts "--flag1=", "--flag3="
      end
    }

    it "raises exception on required_for constraint violation" do
      expect { parser.parse(["--flag1=flag1"]) }.to raise_error(Homebrew::CLI::OptionConstraintError)
    end

    it "raises exception on depends_on constraint violation" do
      expect { parser.parse(["--flag2=flag2"]) }.to raise_error(Homebrew::CLI::OptionConstraintError)
      expect { parser.parse(["--flag4=flag4"]) }.to raise_error(Homebrew::CLI::OptionConstraintError)
    end

    it "raises exception for conflict violation" do
      expect { parser.parse(["--flag1=flag1", "--flag3=flag3"]) }.to raise_error(Homebrew::CLI::OptionConflictError)
    end

    it "raises no exception" do
      parser.parse(["--flag1=flag1", "--flag2=flag2"])
      expect(Homebrew.args.flag1).to eq "flag1"
      expect(Homebrew.args.flag2).to eq "flag2"
    end

    it "raises no exception for optional dependency" do
      parser.parse(["--flag3=flag3"])
      expect(Homebrew.args.flag3).to eq "flag3"
    end
  end

  describe "test invalid constraints" do
    subject(:parser) {
      described_class.new do
        flag      "--flag1="
        flag      "--flag2=", depends_on: "--flag1="
        conflicts "--flag1=", "--flag2="
      end
    }

    it "raises exception due to invalid constraints" do
      expect { parser.parse([]) }.to raise_error(Homebrew::CLI::InvalidConstraintError)
    end
  end

  describe "test constraints for switch options" do
    subject(:parser) {
      described_class.new do
        switch      "-a", "--switch-a", env: "switch_a"
        switch      "-b", "--switch-b", env: "switch_b"
        switch      "--switch-c", required_for: "--switch-a"
        switch      "--switch-d", depends_on: "--switch-b"

        conflicts "--switch-a", "--switch-b"
      end
    }

    it "raises exception on required_for constraint violation" do
      expect { parser.parse(["--switch-a"]) }.to raise_error(Homebrew::CLI::OptionConstraintError)
    end

    it "raises exception on depends_on constraint violation" do
      expect { parser.parse(["--switch-c"]) }.to raise_error(Homebrew::CLI::OptionConstraintError)
      expect { parser.parse(["--switch-d"]) }.to raise_error(Homebrew::CLI::OptionConstraintError)
    end

    it "raises exception for conflict violation" do
      expect { parser.parse(["-ab"]) }.to raise_error(Homebrew::CLI::OptionConflictError)
    end

    it "raises no exception" do
      parser.parse(["--switch-a", "--switch-c"])
      expect(Homebrew.args.switch_a?).to be true
      expect(Homebrew.args.switch_c?).to be true
    end

    it "raises no exception for optional dependency" do
      parser.parse(["--switch-b"])
      expect(Homebrew.args.switch_b?).to be true
    end

    it "prioritizes cli arguments over env vars when they conflict" do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("HOMEBREW_SWITCH_A").and_return("1")
      allow(ENV).to receive(:[]).with("HOMEBREW_SWITCH_B").and_return(nil)
      parser.parse(["--switch-b"])
      expect(Homebrew.args.switch_a).to be_falsy
      expect(Homebrew.args).to be_switch_b
    end

    it "raises an exception on constraint violation when both are env vars" do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with("HOMEBREW_SWITCH_A").and_return("1")
      allow(ENV).to receive(:[]).with("HOMEBREW_SWITCH_B").and_return("1")
      expect { parser.parse([]) }.to raise_error(Homebrew::CLI::OptionConflictError)
    end
  end

  describe "test immutability of args" do
    subject(:parser) {
      described_class.new do
        switch "-a", "--switch-a"
        switch "-b", "--switch-b"
      end
    }

    it "raises exception upon Homebrew.args mutation" do
      parser.parse(["--switch-a"])
      expect { parser.parse(["--switch-b"]) }.to raise_error(RuntimeError, /Arguments were already parsed!/)
    end
  end
end
