class MyUser {
  String id;
  String firstname;
  String lastname;
  String email;
  String password;

  MyUser({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
  });

  MyUser.empty()
      : id = '',
        firstname = '',
        lastname = '',
        email = '',
        password = '';
}
