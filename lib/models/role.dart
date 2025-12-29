class Role {
  static const int actor = 3;
  static const int castingDirector = 2;
  
  static const String actorLabel = 'Actor';
  static const String castingDirectorLabel = 'Casting Director';
  
  static String getRoleLabel(int roleId) {
    switch (roleId) {
      case actor:
        return actorLabel;
      case castingDirector:
        return castingDirectorLabel;
      default:
        return 'Unknown';
    }
  }
  
  static int getRoleId(String roleLabel) {
    switch (roleLabel) {
      case actorLabel:
        return actor;
      case castingDirectorLabel:
        return castingDirector;
      default:
        return 0;
    }
  }
}