module Enterprise::Concerns::Inbox
  extend ActiveSupport::Concern

  included do
    def self.add_response_related_associations
      has_many :response_sources, dependent: :destroy_async
      has_many :response_documents, through: :response_sources
      has_many :responses, through: :response_documents
    end

    add_response_related_associations if Features::ResponseBotService.new.vector_extension_enabled?
  end
end
