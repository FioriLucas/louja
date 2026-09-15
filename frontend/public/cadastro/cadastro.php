<?php
session_start();
if (isset($_SESSION['usr_id'])) {
    header('Location: index.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cadastro - Louja</title>
    <link rel="stylesheet" href="styleCadastro.css">
</head>
<body>

    <div class="login-card" style="max-width: 500px;">
        <h1>Criar Conta</h1>
        <p class="subtitle">Preencha seus dados pessoais e seu endereço de entrega.</p>

        <?php if (isset($_GET['erro'])): ?>
            <div class="alert-error" style="color: red; margin-bottom: 15px;">
                <?php 
                    if ($_GET['erro'] == 'vazio') echo "Preencha todos os campos obrigatórios!";
                    elseif ($_GET['erro'] == 'email_existe') echo "E-mail já cadastrado!";
                    elseif ($_GET['erro'] == 'bd') echo "Erro de banco de dados ao salvar cadastro.";
                    else echo "Erro ao processar o cadastro. Tente novamente.";
                ?>
            </div>
        <?php endif; ?>

        <form action="cadastroBE.php" method="POST">
            <!-- DADOS PESSOAIS -->
            <h3>Dados de Acesso</h3>
            <div class="form-group">
                <input type="text" name="nome" class="input-field" placeholder="Nome Completo *" required>
            </div>
            <div class="form-group">
                <input type="email" name="email" class="input-field" placeholder="E-mail *" required>
            </div>
            <div class="form-group">
                <input type="password" name="senha" class="input-field" placeholder="Senha *" required>
            </div>

            <hr style="margin: 20px 0; border: 0; border-top: 1px solid #ddd;">

            <!-- ENDEREÇO -->
            <h3>Endereço de Entrega</h3>
            <div class="form-group">
                <input type="text" id="cep" name="cep" class="input-field" placeholder="CEP *" maxlength="9" required>
            </div>
            <div class="form-group">
                <input type="text" id="logradouro" name="logradouro" class="input-field" placeholder="Rua / Logradouro *" required>
            </div>
            <div class="form-group" style="display: flex; gap: 10px;">
                <input type="text" name="numero" class="input-field" placeholder="Número *" style="width: 35%;" required>
                <input type="text" name="complemento" class="input-field" placeholder="Complemento (Apt, Bloco)" style="width: 65%;">
            </div>
            <div class="form-group">
                <input type="text" id="bairro" name="bairro" class="input-field" placeholder="Bairro *" required>
            </div>
            <div class="form-group" style="display: flex; gap: 10px;">
                <input type="text" id="cidade" name="cidade" class="input-field" placeholder="Cidade *" style="width: 75%;" required>
                <input type="text" id="estado" name="estado" class="input-field" placeholder="UF *" maxlength="2" style="width: 25%; text-transform: uppercase;" required>
            </div>

            <button type="submit" class="btn-submit" style="margin-top: 15px;">Finalizar Cadastro</button>
        </form>

        <p style="margin-top: 15px; text-align: center;">
            Já possui uma conta? <a href="login.php">Faça login</a>
        </p>
    </div>

    <!-- Script de autopreenchimento de CEP -->
    <script>
        document.getElementById('cep').addEventListener('blur', function() {
            let cep = this.value.replace(/\D/g, '');
            if (cep.length === 8) {
                fetch(`https://viacep.com.br/ws/${cep}/json/`)
                    .then(response => response.json())
                    .then(data => {
                        if (!data.erro) {
                            document.getElementById('logradouro').value = data.logradouro;
                            document.getElementById('bairro').value = data.bairro;
                            document.getElementById('cidade').value = data.localidade;
                            document.getElementById('estado').value = data.uf;
                        }
                    })
                    .catch(err => console.error('Erro ao buscar CEP:', err));
            }
        });
    </script>

</body>
</html>