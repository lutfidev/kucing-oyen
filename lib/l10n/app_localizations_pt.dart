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
  String get splashTagline => 'Bora jogar!';

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
  String get traySlotSelectHint => 'pegar este item';

  @override
  String get traySlotUnselectHint => 'cancelar';

  @override
  String tileLabel(int row, int col, String content) {
    return 'Linha $row, coluna $col: $content';
  }

  @override
  String get cellWall => 'parede';

  @override
  String get cellFloor => 'chão';

  @override
  String get cellBowl => 'tigela do Oyen';

  @override
  String get cellTable => 'mesa';

  @override
  String get cellTableGlass => 'mesa com um copo';

  @override
  String get cellTableVase => 'mesa com um vaso';

  @override
  String get cellFish => 'peixe salgado';

  @override
  String get cellWater => 'poça d\'água';

  @override
  String get cellBox => 'caixa';

  @override
  String tileOyen(String dir) {
    String _temp0 = intl.Intl.selectLogic(dir, {
      'up': 'cima',
      'right': 'a direita',
      'down': 'baixo',
      'left': 'a esquerda',
      'other': 'a direita',
    });
    return 'Oyen dormindo, virado para $_temp0';
  }

  @override
  String tilePlayerItem(String item) {
    return '$item, foi você que colocou';
  }

  @override
  String tileHintSpot(String content) {
    return '$content. Dica: algo tem que ir aqui.';
  }

  @override
  String tileHintItem(String content, String item) {
    return '$content. Dica: $item vai aqui.';
  }

  @override
  String get tilePlaceHint => 'colocar aqui';

  @override
  String get tilePickHint => 'pegar para mudar de lugar';

  @override
  String get tileReturn => 'Devolver aos itens';

  @override
  String itemPickedAnnounce(String item) {
    return '$item na mão. Escolha um quadrado de chão vazio pra colocar.';
  }

  @override
  String itemPlacedAnnounce(String item, int row, int col) {
    return 'Pronto: $item na linha $row, coluna $col.';
  }

  @override
  String itemReturnedAnnounce(String item) {
    return '$item voltou para os itens.';
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
  String get replayPlay => 'Reprodução automática';

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
  String get soundSection => 'Som';

  @override
  String get music => 'Música';

  @override
  String get soundEffects => 'Efeitos sonoros';

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
  String get privacySection => 'Privacidade';

  @override
  String get privacyInfo =>
      'Seu progresso fica no seu celular. Os anúncios vêm do Google AdMob.';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get adConsent => 'Consentimento de anúncios';

  @override
  String get privacyLinkFailed =>
      'O navegador não abriu. Tenta de novo mais tarde, tá?';

  @override
  String get about => 'Sobre';

  @override
  String version(String version) {
    return 'Versão $version';
  }

  @override
  String get fontCredits => 'Fontes: Fredoka e Nunito (SIL Open Font License).';

  @override
  String get soundCredits =>
      'Efeitos sonoros: Kenney e OpenGameArt (CC0). A música foi feita especialmente para o Ginger Logic.';

  @override
  String get licenses => 'Licenças';

  @override
  String get roomItemTikus => 'Ratinho de Brinquedo';

  @override
  String get roomItemTikusDesc => 'Nunca foge, mas é sempre caçado.';

  @override
  String get roomItemAkuarium => 'Aquário';

  @override
  String get roomItemAkuariumDesc =>
      'Diversão o dia inteiro. Os peixes ficam meio nervosos.';

  @override
  String get roomItemRumah => 'Casinha de Gato';

  @override
  String get roomItemRumahDesc => 'Tem a própria casa e dorme na caixa.';

  @override
  String get roomItemKasur => 'Caminha Almofadada';

  @override
  String get roomItemKasurDesc => 'Fofa. Usada 60% do tempo, o resto é caixa.';

  @override
  String get roomItemCatnip => 'Vaso de Catnip';

  @override
  String get roomItemCatnipDesc => 'Uma cheirada e já vem a dancinha.';

  @override
  String get roomItemJam => 'Relógio de Gato';

  @override
  String get roomItemJamDesc => 'A cauda balança a cada segundo. Hipnótico.';

  @override
  String get roomItemKardus => 'Caixa Confortável';

  @override
  String get roomItemKardusDesc =>
      'O escolhido é a caixa, não o que vinha dentro.';

  @override
  String get roomItemBola => 'Bola de Lã';

  @override
  String get roomItemBolaDesc =>
      'Embaraçada em 3 segundos. É recurso, não defeito.';

  @override
  String get roomItemKarpet => 'Tapete Redondo';

  @override
  String get roomItemKarpetDesc => 'O lugar oficial para rolar.';

  @override
  String get roomItemTiang => 'Arranhador';

  @override
  String get roomItemTiangDesc => 'Para o sofá da mãe sobreviver. Tomara.';

  @override
  String get roomItemLukisan => 'Quadro de Peixe';

  @override
  String get roomItemLukisanDesc => 'Arte que dá fome.';

  @override
  String get roomItemRak => 'Prateleira';

  @override
  String get roomItemRakDesc => 'Assento VIP para vigiar todo mundo.';

  @override
  String get roomItemPancingan => 'Varinha de Penas';

  @override
  String get roomItemPancinganDesc =>
      'Corre atrás da pena e deixa a dignidade para trás.';

  @override
  String get roomItemLampuBulan => 'Lâmpada Lua';

  @override
  String get roomItemLampuBulanDesc =>
      'Uma lua particular, sem esperar a noite.';

  @override
  String get roomItemBantalIkan => 'Almofada de Peixe';

  @override
  String get roomItemBantalIkanDesc =>
      'Fofa, e com cara de peixe só na aparência.';

  @override
  String get roomItemMonstera => 'Costela-de-Adão';

  @override
  String get roomItemMonsteraDesc =>
      'As folhas têm buracos. Não foi o Oyen. Dessa vez.';

  @override
  String get roomItemTerowongan => 'Túnel de Gato';

  @override
  String get roomItemTerowonganDesc => 'Entra um gato, sai com estilo.';

  @override
  String get roomItemHammock => 'Rede de Janela';

  @override
  String get roomItemHammockDesc => 'Soneca balançando. Acorda e já é tarde.';

  @override
  String get roomItemSofaMini => 'Sofá Mini';

  @override
  String get roomItemSofaMiniDesc =>
      'Sofá próprio, então o da mãe está seguro. Dizem.';

  @override
  String get roomItemJendelaBurung => 'Janela dos Pássaros';

  @override
  String get roomItemJendelaBurungDesc =>
      'TV de gato 24 horas, só pássaros, sem anúncios.';

  @override
  String get roomItemMangkuk => 'Comedouro';

  @override
  String get kittyOyen => 'Oyen';

  @override
  String get kittyOyenDesc => 'O gato laranja que você acorda em cada nível.';

  @override
  String get kittySalju => 'Neve';

  @override
  String get kittySaljuDesc =>
      'Branquinho. Continua assim até achar uma caixa.';

  @override
  String get kittyTelon => 'Tricolor';

  @override
  String get kittyTelonDesc => 'Três cores, três humores por minuto.';

  @override
  String get kittyArang => 'Carvão';

  @override
  String get kittyArangDesc =>
      'Preto profundo, olhos amarelos. Mestre em se esconder nas sombras.';

  @override
  String get kittyMendung => 'Nublado';

  @override
  String get kittyMendungDesc => 'Parece triste, só está com sono.';

  @override
  String get kittyKopiSusu => 'Latte';

  @override
  String get kittyKopiSusuDesc => 'Doce, meio amargo quando acordado.';

  @override
  String get kittyMochi => 'Mochi';

  @override
  String get kittyMochiDesc => 'Calmo, fofinho, cara de quem brincou na lama.';

  @override
  String get kittyBos => 'Chefe';

  @override
  String get kittyBosDesc => 'Sempre de terno. Reunião em toda hora de comer.';

  @override
  String get kittyKembang => 'Florzinha';

  @override
  String get kittyKembangDesc => 'Manchas abstratas, comportamento também.';

  @override
  String get accessoryPita => 'Fitinha';

  @override
  String get accessoryPitaDesc => 'Simples, fofa, fácil de colocar.';

  @override
  String get accessoryJepitBunga => 'Presilha de Flor';

  @override
  String get accessoryJepitBungaDesc =>
      'Sempre florida, nunca precisa de água.';

  @override
  String get accessoryBandana => 'Bandana';

  @override
  String get accessoryBandanaDesc => 'Estilo caubói de condomínio.';

  @override
  String get accessoryDasiKupu => 'Gravata-Borboleta';

  @override
  String get accessoryDasiKupuDesc => 'Pronto para a festa, sem convite.';

  @override
  String get accessoryKalung => 'Coleira com Sininho';

  @override
  String get accessoryKalungDesc =>
      'Tlim-tlim. Flagrado em todo roubo de peixe.';

  @override
  String get accessorySyal => 'Cachecol de Tricô';

  @override
  String get accessorySyalDesc =>
      'Quentinho. Tricotado por uma vovó imaginária.';

  @override
  String get accessoryBeanie => 'Gorro';

  @override
  String get accessoryBeanieDesc => 'Quentinho. Mesmo com calor lá fora.';

  @override
  String get accessoryTopiKoki => 'Chapéu de Chef';

  @override
  String get accessoryTopiKokiDesc => 'Cozinhar? Não. Provar? Sempre.';

  @override
  String get accessoryBaret => 'Boina';

  @override
  String get accessoryBaretDesc =>
      'Artista instantâneo. Obra-prima: almofada rasgada.';

  @override
  String get accessoryKacamata => 'Óculos Redondos';

  @override
  String get accessoryKacamataDesc =>
      'Parece inteligente. Ainda derruba o vaso.';

  @override
  String get accessoryHeadphone => 'Fones de Ouvido';

  @override
  String get accessoryHeadphoneDesc => 'Lo-fi ligado, fingindo estar ocupado.';

  @override
  String get accessoryTandukRusa => 'Chifres de Rena';

  @override
  String get accessoryTandukRusaDesc =>
      'Rena de mentirinha. Mia do mesmo jeito.';

  @override
  String get accessoryTopiPesta => 'Chapéu de Festa';

  @override
  String get accessoryTopiPestaDesc =>
      'Todo dia é aniversário quando você é gato.';

  @override
  String get accessoryTopiPenyihir => 'Chapéu de Mago';

  @override
  String get accessoryTopiPenyihirDesc => 'Faz peixe aparecer. Dizem.';

  @override
  String get accessoryMahkota => 'Coroa de Flores';

  @override
  String get accessoryMahkotaDesc => 'Rainha do quarto. Não coma as flores.';

  @override
  String get accessoryMahkotaRaja => 'Coroa de Rei';

  @override
  String get accessoryMahkotaRajaDesc =>
      'Rei do quarto. Impostos pagos em carinho.';

  @override
  String get snackIkanAsin => 'Peixe Salgado';

  @override
  String get snackIkanAsinDesc =>
      'Salgado, saboroso, o vizinho sente o cheiro.';

  @override
  String get snackSusu => 'Leite';

  @override
  String get snackSusuDesc => 'Um pratinho. O bigode fica branco.';

  @override
  String get snackTuna => 'Atum em Lata';

  @override
  String get snackTunaDesc => 'O som da lata chama todos os gatos.';

  @override
  String get snackBiskuit => 'Biscoitos de Gato';

  @override
  String get snackBiskuitDesc => 'Crocante e barato. Enche pouco.';

  @override
  String get snackPuding => 'Pudim de Peixe';

  @override
  String get snackPudingDesc => 'Chique. Enche muito, alegra muito.';

  @override
  String get rarityCommon => 'Comum';

  @override
  String get rarityRare => 'Raro';

  @override
  String get raritySpecial => 'Especial';

  @override
  String get shop => 'Loja';

  @override
  String get shopTabItems => 'Objetos';

  @override
  String get shopTabKitties => 'Gatos';

  @override
  String get shopTabAccessories => 'Acessórios';

  @override
  String get shopTabSnacks => 'Comida';

  @override
  String get shopKittyIntro =>
      'Todos os gatos moram no quarto do Oyen. O Oyen concorda. Acho.';

  @override
  String get shopSnackIntro =>
      'Os petiscos vão para o estoque. Entregue pela ficha do gato no quarto.';

  @override
  String get shopOwnedTag => 'Seu';

  @override
  String get shopLivesHere => 'Mora no quarto';

  @override
  String get shopNotEnoughTag => 'Moedas de menos';

  @override
  String shopShortBy(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Faltam $n moedas',
      one: 'Falta $n moeda',
    );
    return '$_temp0';
  }

  @override
  String shopAdopt(int n) {
    return 'Adotar · $n';
  }

  @override
  String shopBuyShort(int n) {
    return 'Comprar · $n';
  }

  @override
  String shopStock(int n) {
    return 'Estoque: $n';
  }

  @override
  String get shopTryOn => 'Testar em:';

  @override
  String shopPreviewOf(String name) {
    return 'Prévia · $name';
  }

  @override
  String get shopWearFree => 'Usar · Grátis';

  @override
  String get shopRemoveFree => 'Tirar · Grátis';

  @override
  String get shopPlayFirst => 'Jogue um quebra-cabeça, as moedas vêm depois.';

  @override
  String shopWornBy(String name) {
    return 'Usado por $name';
  }

  @override
  String get shopFlashNice => 'Ficou lindo!';

  @override
  String get shopFlashRemoved => 'Tirado, de graça';

  @override
  String shopFlashSpent(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '-$n moedas',
      one: '-$n moeda',
    );
    return '$_temp0';
  }

  @override
  String shopPreviewPickLabel(String name) {
    return 'Testar o acessório em $name';
  }

  @override
  String shopCardBuyLabel(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n moedas',
      one: '$n moeda',
    );
    return '$name, $_temp0';
  }

  @override
  String shopCardShortLabel(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n moedas',
      one: '$n moeda',
    );
    return '$name, $_temp0, moedas de menos';
  }

  @override
  String shopCardOwnedLabel(String name) {
    return '$name, já é seu';
  }

  @override
  String shopCardLivesLabel(String name) {
    return '$name, já mora no quarto';
  }

  @override
  String shopAccessoryViewLabel(String name) {
    return 'Ver $name';
  }

  @override
  String shopSnackBuyLabel(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n moedas',
      one: '$n moeda',
    );
    return 'Comprar $name por $_temp0';
  }

  @override
  String shopSnackShortLabel(String name, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n moedas',
      one: '$n moeda',
    );
    return 'Comprar $name por $_temp0, moedas de menos';
  }

  @override
  String buySheetLabel(String name) {
    return 'Comprar $name';
  }

  @override
  String get buySuccessOverline => 'Sucesso!';

  @override
  String buySuccessItem(String name) {
    return '$name agora é seu!';
  }

  @override
  String get buySuccessItemBody => 'Está no depósito. Coloque no modo Decorar.';

  @override
  String buySuccessKitty(String name) {
    return '$name se mudou para o quarto!';
  }

  @override
  String get buySuccessKittyBody =>
      'Diga oi no quarto. Talvez finja não ligar no começo.';

  @override
  String buySuccessAccessory(String name) {
    return '$name é seu para sempre!';
  }

  @override
  String buySuccessAccessoryBody(String name) {
    return 'Coloque no $name agora, ou passe para outro gato quando quiser.';
  }

  @override
  String get buyAccessoryInfo =>
      'Compre uma vez, é seu para sempre. Colocar e tirar é grátis, para todos os gatos.';

  @override
  String buyPay(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n moedas',
      one: '$n moeda',
    );
    return 'Comprar · $_temp0';
  }

  @override
  String get buyLater => 'Fica para depois';

  @override
  String get buyAgain => 'Continuar comprando';

  @override
  String get buySeeRoom => 'Ver no quarto';

  @override
  String buyWearOn(String name) {
    return 'Usar no $name';
  }

  @override
  String get buyNotEnoughHelp =>
      'Jogue um quebra-cabeça ou veja um anúncio premiado para ganhar moedas.';

  @override
  String kittyPose(String pose) {
    String _temp0 = intl.Intl.selectLogic(pose, {
      'idle': 'sentado quietinho',
      'lick': 'lambendo a patinha',
      'walk1': 'andando',
      'walk2': 'andando',
      'sleep': 'dormindo enroladinho',
      'eat': 'comendo da tigela',
      'play': 'brincando com o brinquedo',
      'scratch': 'arranhando o poste',
      'happy': 'feliz',
      'lesu': 'sem ânimo',
      'rebah': 'deitado de boa',
      'petted': 'recebendo carinho, ronronando',
      'other': 'sentado quietinho',
    });
    return '$_temp0';
  }

  @override
  String kittyLabel(String name, String pose) {
    return '$name $pose';
  }

  @override
  String kittyLabelAccessory(String name, String pose, String accessory) {
    return '$name $pose, usando $accessory';
  }
}
