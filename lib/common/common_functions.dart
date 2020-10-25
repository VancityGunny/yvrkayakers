class CommonFunctions {
  static String translateRiverDifficulty(double riverDifficulty) {
    switch ((riverDifficulty * 10).round()) {
      case 20:
        return 'II';
        break;
      case 25:
        return 'II+';
        break;
      case 30:
        return 'III';
        break;
      case 35:
        return 'III+';
        break;
      case 40:
        return 'IV';
        break;
      case 45:
        return 'IV+';
        break;
      case 50:
        return 'V';
        break;
    }
    return ''; //default return nothing
  }
}
