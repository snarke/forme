require 'forme'

module Forme
  module Sinatra
    class Form < ::Forme::Form
      def tag(type, attr={}, children=[], &block)
        tag = Tag.new(type, attr, children)
        if block && children.empty?
          output = eval('@_out_buf', block.binding)
          output << serializer.serialize_open(tag)
          yield self
          output << serializer.serialize_close(tag)
        else
          serialize(tag)
        end
      end
    end
    module ERB
      def form(obj=nil, attr={}, opts={}, &block)
        if obj.is_a?(Hash)
          raise Error, "Can't provide 3 hash arguments to form" unless opts.empty?
          opts = attr
          attr = obj
          Form.new(opts).tag(:form, attr, &block)
        else
          Form.new(obj, opts).tag(:form, attr, &block)
        end
      end
    end 
    Erubis = ERB
  end
end
