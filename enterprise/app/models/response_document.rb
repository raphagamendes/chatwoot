# == Schema Information
#
# Table name: response_documents
#
#  id                 :bigint           not null, primary key
#  content            :text
#  document_link      :string
#  document_type      :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_id         :bigint           not null
#  document_id        :bigint
#  response_source_id :bigint           not null
#
# Indexes
#
#  index_response_documents_on_document            (document_type,document_id)
#  index_response_documents_on_response_source_id  (response_source_id)
#
class ResponseDocument < ApplicationRecord
  has_many :responses, dependent: :destroy
  belongs_to :account
  belongs_to :response_source

  before_validation :set_account
  validates :document_link, length: { maximum: Limits::URL_LENGTH_LIMIT }
  after_create :ensure_content
  after_update :handle_content_change

  private

  def set_account
    self.account = response_source.account
  end

  def ensure_content
    return unless content.nil?

    ResponseDocumentContentJob.perform_later(self)
  end

  def handle_content_change
    return unless saved_change_to_content? && content.present?

    ResponseBuilderJob.perform_later(self)
  end
end
