module NetuitiveRailsAgent
  class ActionMailerTest < Test::Unit::TestCase
    def setup
      @interaction = mock
      @sub = NetuitiveRailsAgent::ActionMailerSub.new(@interaction)
      NetuitiveRailsAgent::ConfigManager.load_config
    end

    def test_receive
      @interaction.expects(:aggregate_metric).with('action_mailer.test_mailer.receive', 1)
      @sub.receive(nil, nil, nil, nil, mailer: 'test_mailer')
    end

    def test_deliver
      @interaction.expects(:aggregate_metric).with('action_mailer.test_mailer.deliver', 1)
      @sub.deliver(nil, nil, nil, nil, mailer: 'test_mailer')
    end
  end
end
