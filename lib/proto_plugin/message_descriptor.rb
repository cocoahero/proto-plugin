# frozen_string_literal: true

module ProtoPlugin
  # A wrapper class around `Google::Protobuf::DescriptorProto`
  # which provides helpers and more idiomatic Ruby access patterns.
  #
  # Any method not defined directly is delegated to the descriptor the wrapper was initialized with.
  #
  # @see https://github.com/protocolbuffers/protobuf/blob/main/src/google/protobuf/descriptor.proto#L134
  #   Google::Protobuf::DescriptorProto
  class MessageDescriptor < SimpleDelegator
    # @return [Google::Protobuf::DescriptorProto]
    attr_reader :descriptor

    # The file or message descriptor this message was defined within.
    #
    # @return [FileDescriptor] if defined as a root message
    # @return [MessageDescriptor] if defined as a nested message (inverse of `nested_type`)
    attr_reader :parent

    # @param descriptor [Google::Protobuf::DescriptorProto]
    # @param parent [FileDescriptorFileDescriptorProto, MessageDescriptor]
    #   The file or message descriptor this message was defined within.
    def initialize(descriptor, parent)
      super(descriptor)
      @descriptor = descriptor
      @parent = parent
    end

    # The messages defined as children of this message.
    #
    # @return [Array]
    #
    # @see https://github.com/protocolbuffers/protobuf/blob/main/src/google/protobuf/descriptor.proto#L140
    #   Google::Protobuf::DescriptorProto#nested_type
    def messages
      @nested_messages ||= @descriptor.nested_type.map do |m|
        MessageDescriptor.new(m, self)
      end
    end

    # The full name of the message, including parent namespace.
    #
    # @example
    #   "My::Ruby::Package::MessageName"
    #
    # @return [String]
    def full_name
      @full_name ||= begin
        prefix = case parent
        when MessageDescriptor
          parent.full_name
        when FileDescriptor
          parent.namespace
        end
        "#{prefix}::#{name}"
      end
    end
  end
end
