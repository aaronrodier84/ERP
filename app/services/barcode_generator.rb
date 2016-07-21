# frozen_string_literal: true
require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/prawn_outputter'

class BarcodeGenerator
  include Prawn::Measurements

  MAX_TITLE_LENGTH = 26

  HORIZONTAL_POSITION = 17
  NEW_CAPTION_POSITION = [HORIZONTAL_POSITION, 10].freeze
  TITLE_POSITION = [HORIZONTAL_POSITION, 29].freeze
  FNSKU_POSITION = [HORIZONTAL_POSITION, 41].freeze
  BARCODE_VERTICAL_POSITION = 51

  SIZE = 8

  def create_barcode(title, fnsku, filename)
    barcode = Barby::Code128A.new(fnsku)
    height = in2pt(1.26)
    width = in2pt(1.86)
    title = title.truncate MAX_TITLE_LENGTH

    pdf = Prawn::Document.new(page_size: [width, height], page_layout: :portrait, margin: 0)

    pdf.draw_text 'New', at: NEW_CAPTION_POSITION, size: SIZE
    pdf.draw_text title, at: TITLE_POSITION, size: SIZE
    pdf.draw_text fnsku, at: FNSKU_POSITION, size: SIZE

    barcode.annotate_pdf(pdf, xdim: 0.68, height: 30, x: HORIZONTAL_POSITION, y: BARCODE_VERTICAL_POSITION)
    pdf.render_file filename
  end
end
