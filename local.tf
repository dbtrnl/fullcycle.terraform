# resource = bloco
# local = provider
# file = tipo do provider
# nome do resource ("exemplo")
# Ver docs: registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file.html
resource "local_file" "exemplo" {
    filename = "exemplo.txt"
    content = "Hello world!\n"
}