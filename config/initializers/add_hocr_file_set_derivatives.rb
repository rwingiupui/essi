module FileSetDerivativesServiceExtensions
  def create_derivatives(filename)
    super
    case mime_type
      when *file_set.class.image_mime_types
        create_hocr_derivatives(filename)
        create_word_boundaries
    end
  end

  private
    def create_hocr_derivatives(filename)
      return unless ESSI.config.dig(:essi, :create_hocr_files)
      OCRRunner.create(filename,
                       { source: :original_file,
                         outputs: [{ label: "#{file_set.id}-alto.xml",
                                     mime_type: 'text/html; charset=utf-8',
                                     format: 'xml',
                                     container: 'extracted_text',
                                     language: file_set.ocr_language,
                                     url: uri }]})
    end

    def create_word_boundaries
      return unless ESSI.config.dig(:essi, :create_word_boundaries)
      file_set.reload
      return unless file_set.extracted_text.present?
      WordBoundariesRunner.create(file_set,
                       { source: :extracted_text,
                         outputs: [{ label: "#{file_set.id}-json.json",
                                     mime_type: 'application/json; charset=utf-8',
                                     format: 'json',
                                     container: 'transcript',
                                     url: uri }]})

    end
end

Hyrax::FileSetDerivativesService.class_eval do
  prepend FileSetDerivativesServiceExtensions
end
