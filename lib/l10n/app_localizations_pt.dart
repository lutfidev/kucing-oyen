// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get backToHome => 'Voltar ao início';

  @override
  String get backToMap => 'Voltar ao mapa';

  @override
  String get close => 'Fechar';

  @override
  String get cancel => 'Cancelar';

  @override
  String starsOf(int stars, int total) {
    return '$stars de $total estrelas';
  }

  @override
  String coinsAmount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n moedas',
      one: '$n moeda',
    );
    return '$_temp0';
  }

  @override
  String coinsUnit(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'moedas',
      one: 'moeda',
    );
    return '$_temp0';
  }

  @override
  String notEnoughCoins(int n) {
    return 'Moedas insuficientes · $n';
  }

  @override
  String get watchAd => 'Ver anúncio';

  @override
  String get adFailed => 'O anúncio não rolou. Tenta de novo mais tarde, tá?';

  @override
  String get boardLabel => 'Tabuleiro de 7 por 9 quadrados';

  @override
  String get play => 'Jogar';

  @override
  String get closet => 'Guarda-roupa';

  @override
  String get settings => 'Configurações';

  @override
  String get tagline => 'Oyen não obedece. Quem pensa é você.';

  @override
  String get starTotalUnit => 'estrelas';

  @override
  String chapterNumber(int n) {
    return 'Capítulo $n';
  }

  @override
  String get chapter1Name => 'Cozinha';

  @override
  String get chapter2Name => 'Sala de Estar';

  @override
  String chapterTitle(int n, String name) {
    return 'Capítulo $n – $name';
  }

  @override
  String get chapterDone => 'Concluído';

  @override
  String get chapterLocked => 'Bloqueado';

  @override
  String get statusDone => 'concluído';

  @override
  String get statusLocked => 'bloqueado';

  @override
  String get statusPlayNow => 'jogar agora';

  @override
  String nodeStars(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n estrelas',
      one: '$n estrela',
    );
    return '$_temp0';
  }

  @override
  String levelNodeLabel(int id, String status) {
    return 'Fase $id, $status';
  }

  @override
  String bossNodeLabel(int id, String name, String status) {
    return 'Fase $id, chefão $name, $status';
  }

  @override
  String bossTag(String name) {
    return 'Chefão · $name';
  }

  @override
  String get chapterMissing => 'Esse capítulo não existe.';

  @override
  String get level1Name => 'Acorda, Oyen';

  @override
  String get level2Name => 'Virando a Esquina';

  @override
  String get level3Name => 'Primeiro Peixe';

  @override
  String get level4Name => 'Peixe Mais Perto';

  @override
  String get level5Name => 'Dois Peixes';

  @override
  String get level6Name => 'Primeiro Balde';

  @override
  String get level7Name => 'Poça';

  @override
  String get level8Name => 'Peixe e Balde';

  @override
  String get level9Name => 'Peixe Tentador';

  @override
  String get level10Name => 'Festa do Peixe Salgado';

  @override
  String get level11Name => 'Mesa de Centro';

  @override
  String get level12Name => 'Copo no Chão';

  @override
  String get level13Name => 'O Vaso da Mamãe';

  @override
  String get level14Name => 'Caixa no Caminho';

  @override
  String get level15Name => 'Caixa Amassada';

  @override
  String get level16Name => 'Volta Longa';

  @override
  String get level17Name => 'Dois Vasos';

  @override
  String get level18Name => 'Aperto';

  @override
  String get level19Name => 'Todos Juntos';

  @override
  String get level20Name => 'Dia do Eid';

  @override
  String bossLevelName(String name) {
    return 'CHEFÃO: $name';
  }

  @override
  String levelTitle(int id, String name) {
    return 'Fase $id · $name';
  }

  @override
  String get rules => 'Regras';

  @override
  String get hint => 'Dica';

  @override
  String targetItems(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'use $n itens',
      one: 'use $n item',
    );
    return '$_temp0';
  }

  @override
  String targetLabel(String text) {
    return 'Meta de 3 estrelas: $text';
  }

  @override
  String get levelMissing => 'Essa fase não existe.';

  @override
  String get backToArrange => 'Voltar à montagem';

  @override
  String get wakeOyen => 'Acordar Oyen';

  @override
  String get trayEmpty => 'Essa fase ainda não precisa de itens.';

  @override
  String get trayLabel => 'Itens';

  @override
  String get clearBoard => 'Limpar o tabuleiro';

  @override
  String get trayHintTop => 'Solte num';

  @override
  String get trayHintBottom => 'quadrado aceso';

  @override
  String get itemFish => 'Peixe salgado';

  @override
  String get itemWater => 'Balde de água';

  @override
  String get itemBox => 'Caixa';

  @override
  String traySlotLabel(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'restam $n',
      one: 'resta $n',
    );
    return '$name, $_temp0';
  }

  @override
  String traySlotDragging(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'restam $n',
      one: 'resta $n',
    );
    return '$name, arrastando, $_temp0';
  }

  @override
  String get step => 'Passo';

  @override
  String stepNumber(int n) {
    return 'Passo $n';
  }

  @override
  String get vaseBroken => 'Vaso quebrado';

  @override
  String get vaseSafe => 'Vaso inteiro';

  @override
  String itemsUsed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n itens usados',
      one: '$n item usado',
    );
    return '$_temp0';
  }

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Continuar';

  @override
  String get stepForward => 'Avançar um passo';

  @override
  String get stepBack => 'Voltar um passo';

  @override
  String get doubleSpeed => 'Velocidade dupla';

  @override
  String get seeResult => 'Ver resultado';

  @override
  String runWake(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'cima',
      'right': 'a direita',
      'down': 'baixo',
      'left': 'a esquerda',
      'other': 'a direita',
    });
    return 'Oyen acorda, virado para $_temp0.';
  }

  @override
  String get runAtBowl => 'Chegou na tigela! Nham nham.';

  @override
  String chaseFish(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'cima',
      'right': 'a direita',
      'down': 'baixo',
      'left': 'a esquerda',
      'other': 'a direita',
    });
    return 'Correndo atrás do peixe para $_temp0.';
  }

  @override
  String runSmellFish(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'lá em cima',
      'right': 'à direita',
      'down': 'lá embaixo',
      'left': 'à esquerda',
      'other': 'à direita',
    });
    return 'Opa, cheiro de peixe salgado $_temp0!';
  }

  @override
  String runWalk(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'cima',
      'right': 'a direita',
      'down': 'baixo',
      'left': 'a esquerda',
      'other': 'a direita',
    });
    return 'Andando reto para $_temp0, de boa.';
  }

  @override
  String get runScared => 'Água! Oyen se assusta e dá meia-volta.';

  @override
  String runTurn(String obstacle, String dir) {
    String _temp0 = intl.Intl.selectLogic(obstacle, {
      'table': 'na mesa',
      'wall': 'na parede',
      'other': 'na parede',
    });
    String _temp1 = intl.Intl.selectLogic(dir, {
      'up': 'cima',
      'right': 'a direita',
      'down': 'baixo',
      'left': 'a esquerda',
      'other': 'a direita',
    });
    return 'Bateu $_temp0. Girou, agora virado para $_temp1.';
  }

  @override
  String get runEat => 'Nhac! Lá se foi o peixe salgado.';

  @override
  String get runEnterBox => 'Uma caixa! Oyen entra e senta.';

  @override
  String get runSit => 'Sentadinho dentro da caixa.';

  @override
  String get runBoxGone => 'A caixa amassa e some.';

  @override
  String get runKnockGlass => 'Empurrou o copo. Ainda bem que é de plástico!';

  @override
  String get runKnockVase => 'Ih! O vaso da Mamãe caiu e quebrou.';

  @override
  String replayAsleep(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'cima',
      'right': 'a direita',
      'down': 'baixo',
      'left': 'a esquerda',
      'other': 'a direita',
    });
    return 'Início: Oyen dormindo, virado para $_temp0.';
  }

  @override
  String replayFinished(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n passos',
      one: '$n passo',
    );
    return 'Na tigela. Pronto em $_temp0.';
  }

  @override
  String get replayChaseVaseSafe => 'Atrás do peixe. Vaso ainda inteiro.';

  @override
  String replaySeeFish(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'para cima',
      'right': 'à direita',
      'down': 'para baixo',
      'left': 'à esquerda',
      'other': 'à direita',
    });
    return 'Peixe salgado à vista, reto $_temp0.';
  }

  @override
  String replayWalk(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'cima',
      'right': 'a direita',
      'down': 'baixo',
      'left': 'a esquerda',
      'other': 'a direita',
    });
    return 'Anda reto para $_temp0.';
  }

  @override
  String replayScared(String water) {
    String _temp0 = intl.Intl.selectLogic(water, {
      'puddle': 'uma poça',
      'bucket': 'um balde de água',
      'other': 'água',
    });
    return 'Encontra $_temp0, se assusta, meia-volta.';
  }

  @override
  String replayTurn(String obstacle, String dir) {
    String _temp0 = intl.Intl.selectLogic(obstacle, {
      'table': 'na mesa',
      'wall': 'na parede',
      'other': 'na parede',
    });
    String _temp1 = intl.Intl.selectLogic(dir, {
      'up': 'cima',
      'right': 'a direita',
      'down': 'baixo',
      'left': 'a esquerda',
      'other': 'a direita',
    });
    return 'Bate $_temp0, gira e fica virado para $_temp1.';
  }

  @override
  String get replayEat => 'Nhac! Peixe salgado comido.';

  @override
  String get replayEnterBox => 'Entra na caixa e senta.';

  @override
  String get replaySit => 'Ainda sentado na caixa.';

  @override
  String get replayBoxGone => 'A caixa amassou e sumiu.';

  @override
  String get replayKnockGlass => 'Copo derrubado. Tranquilo, é de plástico.';

  @override
  String get replayKnockVase => 'Vaso da Mamãe derrubado. Quebrou!';

  @override
  String get replayLoopStart =>
      'De volta ao começo. Oyen fica rodando e se cansa.';

  @override
  String replayLoopStep(int n) {
    return 'Igual ao passo $n. Oyen fica rodando e se cansa.';
  }

  @override
  String replayTooManySteps(int n) {
    return 'Passo $n e nada da tigela. Oyen cansou.';
  }

  @override
  String get closeRules => 'Fechar regras';

  @override
  String get rulesTitle => 'Regras do Oyen';

  @override
  String get rulesIntro =>
      'Cada passo é checado de cima para baixo. A primeira regra que servir é o que o Oyen faz.';

  @override
  String get ruleKnockTitle => 'Derruba o que estiver do lado';

  @override
  String get ruleKnockBody =>
      'Copo ou vaso na mesa do lado? Vai pro chão. Sempre.';

  @override
  String get ruleFishTitle => 'Persegue o peixe mais perto';

  @override
  String get ruleFishBody => 'Só os que estão em linha reta. Se empatar:';

  @override
  String get tieAhead => 'frente';

  @override
  String get tieClockwise => 'sentido horário';

  @override
  String get tieCounterClockwise => 'anti-horário';

  @override
  String get tieBehind => 'trás';

  @override
  String get tieOrderLabel =>
      'Ordem de desempate: frente, sentido horário, anti-horário, trás.';

  @override
  String get ruleWaterTitle => 'Água? Meia-volta';

  @override
  String get ruleWaterBody =>
      'Deu de cara com poça ou balde? Oyen leva um susto e dá meia-volta.';

  @override
  String get ruleWallTitle => 'Bateu na parede ou na mesa';

  @override
  String get ruleWallTurn => 'Oyen gira no sentido horário';

  @override
  String get ruleWallBody => 'Um quarto de volta e segue em frente.';

  @override
  String get ruleBoxTitle => 'Caixa? Entra e senta';

  @override
  String get ruleBoxBody =>
      'Fica 2 passos sentado até a caixa amassar e sumir. Peixe atrás de caixa não aparece.';

  @override
  String get ruleKnockLocked => 'Coisas na mesa';

  @override
  String get ruleFishLocked => 'Peixe';

  @override
  String get ruleWaterLocked => 'Água';

  @override
  String get ruleWallLocked => 'Parede';

  @override
  String get ruleBoxLocked => 'Caixa';

  @override
  String ruleLockedTitle(String name) {
    return '$name: ???';
  }

  @override
  String get ruleLockedBody => 'Ainda não aprendida. Logo vocês se conhecem.';

  @override
  String ruleLabel(int n) {
    return 'Regra $n';
  }

  @override
  String ruleLockedLabel(int n) {
    return 'Regra $n, bloqueada, ainda não aprendida';
  }

  @override
  String get closeHints => 'Fechar dicas';

  @override
  String get hintsTitle => 'Dicas';

  @override
  String get hintsIntro =>
      'Vai com calma. Talvez você só precise de um empurrãozinho.';

  @override
  String get hintTier1Title => 'Destacar o primeiro quadrado';

  @override
  String get hintTier2Title => 'Mostrar o tipo de item';

  @override
  String get hintTier3Title => 'Mostrar a solução completa';

  @override
  String get hintOpened => 'Liberada';

  @override
  String hintTier(int n) {
    return 'Nível $n';
  }

  @override
  String hintUnlockFirst(int n) {
    return 'Libere o nível $n antes';
  }

  @override
  String get noItemsHint =>
      'Essa fase não precisa de itens. É só acordar o Oyen!';

  @override
  String get hintTier1Text =>
      'Viu o quadrado aceso? Tem um item que precisa ir ali.';

  @override
  String get hintPlaceFish =>
      'Coloque um peixe salgado no quadrado aceso. Oyen vai correr atrás e comer.';

  @override
  String get hintPlaceWater =>
      'Coloque um balde de água no quadrado aceso. Oyen vai se assustar e dar meia-volta.';

  @override
  String get hintPlaceBox =>
      'Coloque uma caixa no quadrado aceso. Oyen vai entrar e sentar lá.';

  @override
  String hintFishCount(String count, int n) {
    String _temp0 = intl.Intl.selectLogic(count, {
      'one': 'um peixe salgado',
      'two': 'dois peixes salgados',
      'three': 'três peixes salgados',
      'other': '$n peixes salgados',
    });
    return '$_temp0';
  }

  @override
  String hintWaterCount(String count, int n) {
    String _temp0 = intl.Intl.selectLogic(count, {
      'one': 'um balde de água',
      'two': 'dois baldes de água',
      'three': 'três baldes de água',
      'other': '$n baldes de água',
    });
    return '$_temp0';
  }

  @override
  String hintBoxCount(String count, int n) {
    String _temp0 = intl.Intl.selectLogic(count, {
      'one': 'uma caixa',
      'two': 'duas caixas',
      'three': 'três caixas',
      'other': '$n caixas',
    });
    return '$_temp0';
  }

  @override
  String listPair(String a, String b) {
    return '$a e $b';
  }

  @override
  String listLast(String rest, String last) {
    return '$rest e $last';
  }

  @override
  String hintSolution(String items, int count, String tail) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nos quadrados acesos',
      one: 'no quadrado aceso',
    );
    return '$items $_temp0. $tail';
  }

  @override
  String get hintSolutionVaseSafe => 'Vaso inteiro, 3 estrelas.';

  @override
  String get hintSolutionStars => '3 estrelas!';

  @override
  String get tutorial1Title => 'Ninguém manda no Oyen. É só acordar o gato!';

  @override
  String get tutorial1Body => 'Ele vai sozinho até a tigela. Você só assiste.';

  @override
  String get tutorial3Title => 'Oyen não resiste a peixe salgado!';

  @override
  String get tutorial3Body =>
      'Arraste o peixe para o chão. Se estiver em linha reta, ele sai correndo atrás.';

  @override
  String get tutorial6Title => 'Oyen morre de medo de água.';

  @override
  String get tutorial6Body =>
      'Coloque o balde no caminho. Deu de cara com água, ele se assusta e dá meia-volta.';

  @override
  String get tutorialLabel => 'Tutorial';

  @override
  String get skipTutorial => 'Pular tutorial';

  @override
  String get skip => 'Pular';

  @override
  String get success => 'Conseguiu!';

  @override
  String stepsUnit(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'passos',
      one: 'passo',
    );
    return '$_temp0';
  }

  @override
  String itemsUsedUnit(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'itens usados',
      one: 'item usado',
    );
    return '$_temp0';
  }

  @override
  String get goalBowl => 'Chegou à tigela';

  @override
  String get goalVase => 'Vaso da Mamãe inteiro';

  @override
  String get goalItems => 'Menos itens';

  @override
  String get goalNotYet => 'Ainda não';

  @override
  String get goalGot => 'Feito';

  @override
  String get goalAchieved => 'conseguido';

  @override
  String get restart => 'Recomeçar';

  @override
  String get next => 'Próxima';

  @override
  String get watchReplay => 'Ver o replay';

  @override
  String get vaseHeadlineTop => 'Chegou...';

  @override
  String get vaseHeadlineBottom => 'mas e o vaso da Mamãe?';

  @override
  String brokenAtStep(int n) {
    return 'Quebrou no passo $n';
  }

  @override
  String get tryAgain => 'Tentar de Novo';

  @override
  String get nextAnyway => 'Seguir Assim';

  @override
  String get vaseArtLabel =>
      'O vaso quebrado atrás do Oyen, e a Mamãe aparece na porta, brava';

  @override
  String get loopTitle => 'Oyen cansou de andar em círculos.';

  @override
  String get loopBadge => 'Em círculos';

  @override
  String get loopMessage =>
      'Dá voltas e voltas e nada da tigela. Ah, bora dormir de novo.';

  @override
  String get tooLongTitle => 'Oyen cansou de tanto andar.';

  @override
  String tooLongBadge(int n) {
    return 'Mais de $n passos';
  }

  @override
  String tooLongMessage(int n) {
    return '$n passos e nada da tigela. Cansei. Bora dormir.';
  }

  @override
  String failedKicker(int id) {
    return 'Fase $id · Falhou';
  }

  @override
  String get replay => 'Replay';

  @override
  String get arrangeAgain => 'Reorganizar';

  @override
  String get replayStart => 'Início';

  @override
  String get backToResult => 'Voltar ao resultado';

  @override
  String get recording => 'Gravação';

  @override
  String replayStepCaption(int n, String text) {
    return 'Passo $n. $text';
  }

  @override
  String get timeline => 'Tempo';

  @override
  String oyenLabel(String pose, String dir) {
    String _temp0 = intl.Intl.selectLogic(pose, {
      'idle': 'parado',
      'walk': 'andando',
      'sleep': 'dormindo',
      'shock': 'assustado',
      'box': 'sentado na caixa',
      'knock': 'derrubando algo',
      'eat': 'comendo',
      'happy': 'feliz',
      'other': 'parado',
    });
    String _temp1 = intl.Intl.selectLogic(dir, {
      'up': 'cima',
      'right': 'a direita',
      'down': 'baixo',
      'left': 'a esquerda',
      'other': 'a direita',
    });
    return 'Oyen $_temp0, virado para $_temp1';
  }

  @override
  String get costumeNone => 'Básico';

  @override
  String get costumePeci => 'Peci';

  @override
  String get costumeSarung => 'Sarongue';

  @override
  String get costumeKoki => 'Chapéu de Chef';

  @override
  String get costumeKacamata => 'Óculos';

  @override
  String get costumeWearingTag => 'Usando';

  @override
  String get costumeWearingStatus => 'usando';

  @override
  String get costumeOwnedTag => 'Seu';

  @override
  String get costumeOwnedStatus => 'seu';

  @override
  String get costumeActionWearing => 'Usando agora';

  @override
  String get costumeActionWear => 'Usar';

  @override
  String costumeActionBuy(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Comprar · $n moedas',
      one: 'Comprar · $n moeda',
    );
    return '$_temp0';
  }

  @override
  String get closeCoins => 'Fechar moedas';

  @override
  String get coinsTitle => 'Mais Moedas';

  @override
  String get coinsIntro =>
      'Moedas servem para dicas e roupas do Oyen. Pegue o bônus diário ou veja um anúncio.';

  @override
  String get dailyBonus => 'Bônus diário';

  @override
  String get dailyBonusReady => 'Uma vez por dia';

  @override
  String get dailyBonusTaken => 'Já pegou hoje';

  @override
  String claimCoins(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Pegar $n moedas',
      one: 'Pegar $n moeda',
    );
    return '$_temp0';
  }

  @override
  String get claimTomorrow => 'Volta amanhã';

  @override
  String adsLeftToday(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Restam $n hoje',
      one: 'Resta $n hoje',
    );
    return '$_temp0';
  }

  @override
  String get adsUsedUp => 'Acabou por hoje';

  @override
  String adRewardButton(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n moedas',
      one: '+$n moeda',
    );
    return '$_temp0';
  }

  @override
  String get adsTomorrow => 'Amanhã tem mais';

  @override
  String get coinChipAdd => 'mais moedas';

  @override
  String get coinChipBonus => 'bônus diário pronto';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Idioma do celular';

  @override
  String get tutorialsSection => 'Tutoriais';

  @override
  String get replayTutorials => 'Ver tutoriais de novo';

  @override
  String get replayTutorialsInfo =>
      'Os tutoriais das fases 1, 3 e 6 aparecem de novo na próxima vez que você jogar.';

  @override
  String get tutorialsBack => 'Pronto! Os tutoriais voltaram.';

  @override
  String get progressSection => 'Progresso';

  @override
  String get resetProgress => 'Apagar progresso';

  @override
  String get resetProgressInfo =>
      'Apaga estrelas, moedas, roupas, dicas e tutoriais e recomeça na fase 1.';

  @override
  String get resetConfirmTitle => 'Apagar todo o progresso?';

  @override
  String get resetConfirmBody =>
      'Estrelas, moedas, roupas, dicas e tutoriais serão apagados. Não dá para desfazer. O bônus e os anúncios de hoje continuam contados.';

  @override
  String get resetConfirm => 'Apagar';

  @override
  String get closeReset => 'Fechar apagar progresso';

  @override
  String get resetDone => 'Progresso apagado. Bora recomeçar!';

  @override
  String get about => 'Sobre';

  @override
  String version(String version) {
    return 'Versão $version';
  }

  @override
  String get fontCredits => 'Fontes: Fredoka e Nunito (SIL Open Font License).';

  @override
  String get licenses => 'Licenças';
}
