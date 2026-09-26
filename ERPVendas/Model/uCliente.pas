unit uCliente;
interface

type
  TCliente = class
  private
    FID: Integer;
    FNome: string;
    FCPFCNPJ: string;
    FEmail: string;
    FTelefone: string;
    FAtivo: string;
  public
    property ID: Integer read FID write FID;
    property Nome: string read FNome write FNome;
    property CPFCNPJ: string read FCPFCNPJ write FCPFCNPJ;
    property Email: string read FEmail write FEmail;
    property Telefone: string read FTelefone write FTelefone;
    property Ativo: string read FAtivo write FAtivo;
  end;

implementation
end.
