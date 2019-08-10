# frozen_string_literal: true

require "cmd/uninstall"

require "cmd/shared_examples/args_parse"

describe "Homebrew.uninstall_args" do
  it_behaves_like "parseable arguments"
end

describe "brew uninstall", :integration_test do
  it "uninstalls a given Formula" do
    install_test_formula "testball"

    expect { brew "uninstall", "--force", "testball" }
      .to output(/Uninstalling testball/).to_stdout
      .and not_to_output.to_stderr
      .and be_a_success
  end
end

describe Homebrew do
  let(:dependency) { formula("dependency") { url "f-1" } }
  let(:dependent) do
    formula("dependent") do
      url "f-1"
      depends_on "dependency"
    end
  end

  let(:opts) { { dependency.rack => [Keg.new(dependency.installed_prefix)] } }

  before do
    [dependency, dependent].each do |f|
      f.installed_prefix.mkpath
      Keg.new(f.installed_prefix).optlink
    end

    tab = Tab.empty
    tab.homebrew_version = "1.1.6"
    tab.tabfile = dependent.installed_prefix/Tab::FILENAME
    tab.runtime_dependencies = [
      { "full_name" => "dependency", "version" => "1" },
    ]
    tab.write

    stub_formula_loader dependency
    stub_formula_loader dependent
  end

  describe "::handle_unsatisfied_dependents" do
    specify "when developer" do
      ENV["HOMEBREW_DEVELOPER"] = "1"

      expect {
        described_class.handle_unsatisfied_dependents(opts)
      }.to output(/Warning/).to_stderr

      expect(described_class).not_to have_failed
    end

    specify "when not developer" do
      expect {
        described_class.handle_unsatisfied_dependents(opts)
      }.to output(/Error/).to_stderr

      expect(described_class).to have_failed
    end

    specify "when not developer and --ignore-dependencies is specified" do
      described_class.args = described_class.args.dup if described_class.args.frozen?
      expect(described_class.args).to receive(:ignore_dependencies?).and_return(true)
      described_class.args.freeze

      expect {
        described_class.handle_unsatisfied_dependents(opts)
      }.not_to output.to_stderr

      expect(described_class).not_to have_failed
    end
  end
end
