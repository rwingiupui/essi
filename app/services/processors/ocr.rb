module Processors
  class OCR < Hydra::Derivatives::Processors::Processor
    include Hydra::Derivatives::Processors::ShellBasedProcessor

    def self.encode(path, options, output_file)
      root_file = output_file.gsub('.xml', '')
      hocr_file = "#{root_file}.hocr"
      alto_file = "#{root_file}.tmp.xml"
      execute "tesseract #{path} #{root_file} #{options[:options]} hocr"
      execute "java -classpath \"#{Rails.root.join('lib', 'Saxon-HE.jar')}\"" \
              " net.sf.saxon.Transform -s:#{hocr_file}" \
              " -xsl:#{Rails.root.join('lib', 'hocr2alto2.0.xsl')}" \
              " -o:#{alto_file}"
      execute "xmllint #{alto_file} --format > #{output_file}"
    end

    def options_for(_format)
      {
        options: string_options
      }
    end

    private

      def string_options
        "-l #{language}"
      end

      def language
        directives.fetch(:language, :eng)
      end
  end
end
