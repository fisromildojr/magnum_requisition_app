class Provider {
  String id;
  String fantasyName;
  String email;
  String address;
  String city;
  String uf;
  bool excluded = false;
  List<String> providerSearch = [];

  Provider({
    this.id,
    this.fantasyName,
    this.email,
    this.address,
    this.city,
    this.uf,
    this.excluded,
    this.providerSearch,
  });
}
