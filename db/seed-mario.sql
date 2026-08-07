-- Projeto do Mario de Alencar
-- Execute depois do schema.sql. Troque o e-mail antes de rodar.

do $$
declare
  p uuid;
begin
  insert into projetos (nome, cliente_nome, cliente_email, status, prazo_dias, proposta_url)
  values (
    'O Ponto da Virada — site, loja e captação',
    'Mario de Alencar',
    'TROQUE_PELO_EMAIL_DO_MARIO',
    'aguardando_materiais',
    10,
    'https://meloinfo.com.br/proposta/mario'
  )
  returning id into p;

  insert into itens (projeto_id, tipo, titulo, ordem, status) values
    (p, 'etapa', 'Aguardando materiais', 1, 'enviado'),
    (p, 'etapa', 'Em desenvolvimento',   2, 'pendente'),
    (p, 'etapa', 'Revisão com você',     3, 'pendente'),
    (p, 'etapa', 'Entregue',             4, 'pendente');

  insert into itens (projeto_id, tipo, titulo, descricao, campo_tipo, obrigatorio, ordem) values
    (p, 'requisito', 'E-mail para receber vendas e candidaturas',
     'Para onde envio o aviso de cada venda e cada pedido de consultoria.',
     'email', true, 1),

    (p, 'requisito', 'WhatsApp que vai no site',
     'O número que aparece para quem quiser falar com você.',
     'texto', true, 2),

    (p, 'requisito', 'InfiniteTag da sua InfinitePay',
     'É o apelido do seu perfil no app da InfinitePay, aquele que começa com cifrão. Pode enviar sem o cifrão.',
     'texto', true, 3),

    (p, 'requisito', 'Ativar o Checkout Integrado na InfinitePay',
     'No app da InfinitePay: Vendas → Checkout → Configurações, e ative o Checkout Integrado. Sem isso o pagamento não funciona no site. Não preciso de nenhuma senha sua.',
     'confirmacao', true, 4),

    (p, 'requisito', 'Arquivo final do e-book',
     'O PDF do livro, na versão que vai ser vendida.',
     'arquivo', true, 5),

    (p, 'requisito', 'Capa do livro',
     'A imagem da capa, em boa resolução. Se estiver dentro do PDF, pode pular.',
     'arquivo', false, 6),

    (p, 'requisito', 'Preço do e-book',
     'Quanto vai custar a versão digital.',
     'moeda', true, 7),

    (p, 'requisito', 'Preço do livro físico',
     'Já com o frete embutido, como combinamos.',
     'moeda', true, 8),

    (p, 'requisito', 'Autorização para registrar o domínio',
     'Eu cuido do registro e de toda a configuração técnica — você não precisa mexer em nada. O domínio fica registrado no seu nome, e é seu. Me envie aqui seu nome completo e CPF (ou CNPJ, se preferir no nome da empresa), e a sua preferência de endereço, por exemplo mariodealencar.com.br.',
     'texto', true, 9),

    (p, 'requisito', 'Dados para a Amazon',
     'Para publicar o e-book eu preciso criar sua conta no Kindle Direct Publishing. Ela pede CPF e conta bancária para receber os royalties. Me avise aqui se prefere criar você mesmo e eu te oriento, ou se quer que eu crie e depois te entregue o acesso.',
     'texto', true, 10);

  insert into pagamentos (projeto_id, descricao, valor_centavos, status, pago_em, ordem) values
    (p, 'Entrada (1 de 2)',    65000, 'pago',     current_date, 1),
    (p, 'Na entrega (2 de 2)', 64900, 'pendente', null,         2);
end $$;
