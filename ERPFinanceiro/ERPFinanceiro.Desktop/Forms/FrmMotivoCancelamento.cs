using System.Drawing;
using System.Windows.Forms;

namespace ERPFinanceiro.Desktop.Forms;

public class FrmMotivoCancelamento : Form
{
    private readonly TextBox _txt = new();
    public string Motivo => _txt.Text.Trim();

    public FrmMotivoCancelamento()
    {
        Text = "Motivo do cancelamento";
        Width = 520;
        Height = 220;
        StartPosition = FormStartPosition.CenterParent;

        var label = new Label { Text = "Informe o motivo:", Dock = DockStyle.Top, Height = 30 };
        _txt.Multiline = true;
        _txt.Dock = DockStyle.Fill;

        var ok = new Button { Text = "Confirmar", DialogResult = DialogResult.OK, Width = 100 };
        var cancelar = new Button { Text = "Cancelar", DialogResult = DialogResult.Cancel, Width = 100 };
        var panel = new FlowLayoutPanel { Dock = DockStyle.Bottom, Height = 48, FlowDirection = FlowDirection.RightToLeft };
        panel.Controls.Add(cancelar);
        panel.Controls.Add(ok);

        Controls.Add(_txt);
        Controls.Add(label);
        Controls.Add(panel);
        AcceptButton = ok;
        CancelButton = cancelar;
    }
}
