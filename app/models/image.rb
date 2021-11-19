# frozen_string_literal: true

class Image
  include Mongoid::Document
  include Mongoid::Paperclip

  embedded_in :conexao, inverse_of: :images

  has_mongoid_attached_file :content
  validates_attachment_content_type :content,
                                    content_type: ['image/jpg', 'image/jpeg', 'image/png',
                                                   'image/gif']
end
