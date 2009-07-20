module ElementHelpers

  #  class JavaScriptHelperTest < ActiveSupport::TestCase
  #  include SeleniumHelpers
  #  include ElementHelpers
  #
  #  def setup
  #    @element = locate('#all')
  #  end
  #
  #  def test_visible_by_default
  #    assert @element.visible?
  #  end
  #
  #  def test_hide_element
  #    @element.hide!
  #    assert ! @element.visible?
  #  end
  #
  #  def test_show_element
  #    @element.hide! # setup
  #    @element.show!
  #    assert @element.visible?
  #  end
  #end

  class Element
    def initialize(context, selector)
      @context, @selector = context, selector
    end

    def hide!
      call(:hide)
    end

    def show!
      call(:show)
    end

    def visible?
      call(:is, ':visible') == 'true'
    end

    private

    def call(fn, *args)
      @context.run_javascript <<-JS
return jQuery(#{@selector.inspect})[#{fn.to_s.inspect}](#{args.map(&:inspect).join(', ')});
      JS
    end
  end

  def locate(selector)
    Element.new(self, selector)
  end
end

World(ElementHelpers)