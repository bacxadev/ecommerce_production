require 'google/apis/sheets_v4'
require 'googleauth'

class CleanSheetService
  def execute
    clean_sheet
  end

  private
  attr_reader :params

  def clean_sheet
    GoogleSheetService.new().execute

    service_account_info = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(Rails.root.join('weighty-media-422515-r1-82d57046508d.json')),
      scope: 'https://www.googleapis.com/auth/spreadsheets'
    )

    service = Google::Apis::SheetsV4::SheetsService.new
    service.authorization = service_account_info

    spreadsheet_id = '1H3A6jrM11jk-8JXKRC9hQ27D1hqjROKwPc70gyHChT8'
    range = 'Sheet1!A2:I'

    clear_values_request_body = Google::Apis::SheetsV4::ClearValuesRequest.new
    service.clear_values(spreadsheet_id, range, clear_values_request_body)
  end
end
