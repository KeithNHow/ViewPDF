namespace KNHViewPDF;
using Microsoft.Sales.History;
using Microsoft.Foundation.Reporting;
using System.Utilities;

pageextension 54500 "KNH Posted Sales Invoices" extends "Posted Sales Invoices"
{
    actions
    {
        addafter("&Invoice")
        {
            action(OpenSelectedInvoiceInFileViewer)
            {
                ApplicationArea = All;
                Caption = 'View PDF';
                ToolTip = 'View PDF';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ReportSelection: Record "Report Selections";
                    SalesInvHeader: Record "Sales Invoice Header";
                    TempReportSelections: Record "Report Selections" temporary;
                    TempBlob: Codeunit "Temp Blob";
                    PdfFileName: Text;
                    InStr: InStream;
                begin
                    SalesInvHeader.Reset();
                    CurrPage.SetSelectionFilter(SalesInvHeader);
                    if SalesInvHeader.FindFirst() then begin
                        SalesInvHeader.SetRecFilter();
                        ReportSelection.FindReportUsageForCust(Enum::"Report Selection Usage"::"S.Invoice", SalesInvHeader."Bill-to Customer No.", TempReportSelections);
                        Clear(TempBlob);
                        TempReportSelections.SaveReportAsPDFInTempBlob(TempBlob, TempReportSelections."Report ID", SalesInvHeader, TempReportSelections."Custom Report Layout Code", Enum::"Report Selection Usage"::"S.Invoice");
                        TempBlob.CreateInStream(InStr);
                        PdfFileName := Format(SalesInvHeader."No." + '.pdf');
                        File.DownloadFromStream(InStr, 'Export', 'All Files (*.*)|*.*', '', PdfFileName);
                        //File.ViewFromStream(InStreeam, PdfFileName + '.' + 'pdf', true); //V26.0
                    end;
                end;
            }
        }
    }
}