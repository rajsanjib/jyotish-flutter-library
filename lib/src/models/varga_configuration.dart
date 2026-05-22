enum HoraMethod {
  parashara,
  labhaMandooka,
  kura,
  kashinatha,
}

enum DrekkanaMethod {
  parashara,
  jagannatha,
  somanatha,
  parivritti,
}

enum NavamshaMethod {
  parashara,
  krishnaMishra,
  somanatha,
  nadamsa,
}

enum DashamshaMethod {
  parashara,
  behari,
}

/// Configuration class specifying custom algorithms for divisional charts (Vargas).
class VargaConfiguration {
  const VargaConfiguration({
    this.horaMethod = HoraMethod.parashara,
    this.drekkanaMethod = DrekkanaMethod.parashara,
    this.navamshaMethod = NavamshaMethod.parashara,
    this.dashamshaMethod = DashamshaMethod.parashara,
  });

  final HoraMethod horaMethod;
  final DrekkanaMethod drekkanaMethod;
  final NavamshaMethod navamshaMethod;
  final DashamshaMethod dashamshaMethod;
}
