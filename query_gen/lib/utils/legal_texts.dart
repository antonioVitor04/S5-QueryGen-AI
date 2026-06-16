class LegalSection {
  final String title;
  final String content;
  const LegalSection(this.title, this.content);
}

class LegalTexts {
  LegalTexts._();

  static const termsSubtitle =
      'Ao utilizar esta plataforma, você concorda com todos os termos e condições estabelecidos neste documento.';

  static const termsSections = [
    LegalSection('1. Uso da Plataforma',
        'O usuário se compromete a utilizar o sistema de forma responsável, ética e dentro das leis vigentes. O acesso à plataforma é pessoal e intransferível.'),
    LegalSection('2. Conta do Usuário',
        'Você é responsável pela segurança da sua conta e das informações fornecidas durante o cadastro. Mantenha sua senha em sigilo e não compartilhe suas credenciais.'),
    LegalSection('3. Proibições',
        'É proibido utilizar a plataforma para spam, ataques ou qualquer atividade maliciosa. Tentativas de acesso não autorizado serão reportadas às autoridades competentes.'),
    LegalSection('4. Propriedade Intelectual',
        'Todo o conteúdo disponível na plataforma é protegido por direitos autorais. É vedada a reprodução, distribuição ou modificação sem autorização prévia.'),
    LegalSection('5. Limitação de Responsabilidade',
        'A plataforma não se responsabiliza por danos indiretos decorrentes do uso ou da incapacidade de uso dos serviços oferecidos.'),
    LegalSection('6. Alterações nos Termos',
        'Reservamos o direito de modificar estes termos a qualquer momento. O uso continuado da plataforma após as alterações constitui aceitação dos novos termos.'),
  ];

  static const privacySubtitle =
      'Sua privacidade é importante para nós. Todas as informações fornecidas são protegidas e armazenadas com segurança.';

  static const privacySections = [
    LegalSection('1. Coleta de Dados',
        'Coletamos apenas informações necessárias para o funcionamento da plataforma, como nome, e-mail e dados de uso. Não coletamos dados sensíveis sem consentimento explícito.'),
    LegalSection('2. Compartilhamento',
        'Não compartilhamos seus dados pessoais com terceiros sem autorização, exceto quando exigido por lei ou para prestação dos serviços contratados.'),
    LegalSection('3. Segurança',
        'Aplicamos medidas técnicas e organizacionais para proteger suas informações contra acesso não autorizado, perda ou destruição acidental.'),
    LegalSection('4. Cookies',
        'Utilizamos cookies para melhorar sua experiência na plataforma. Você pode desativá-los nas configurações do seu navegador, mas isso pode afetar algumas funcionalidades.'),
    LegalSection('5. Seus Direitos',
        'Você tem direito de acessar, corrigir ou solicitar a exclusão de seus dados pessoais a qualquer momento, conforme previsto pela LGPD.'),
    LegalSection('6. Retenção de Dados',
        'Mantemos seus dados pelo tempo necessário para a prestação dos serviços ou conforme exigido por obrigações legais. Após esse período, os dados são excluídos com segurança.'),
  ];
}
