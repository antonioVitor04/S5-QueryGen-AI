const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

async function enviarEmailRecuperacao(emailDestino, token) {
  await transporter.sendMail({
    from: `"SAP AI Scripts" <${process.env.EMAIL_USER}>`,
    to: emailDestino,
    subject: 'Código de recuperação de conta',
    html: `
      <div style="font-family: sans-serif; max-width: 400px; margin: auto;">
        <h2>Recuperação de conta</h2>
        <p>Seu código de verificação é:</p>
        <div style="font-size: 36px; font-weight: bold; letter-spacing: 8px; 
                    text-align: center; padding: 20px; background: #f4f4f4; 
                    border-radius: 8px; margin: 20px 0;">
          ${token}
        </div>
        <p style="color: #888; font-size: 13px;">
          Este código expira em 15 minutos.<br>
          Se você não solicitou a recuperação, ignore este email.
        </p>
      </div>
    `,
  });
}

module.exports = { enviarEmailRecuperacao };