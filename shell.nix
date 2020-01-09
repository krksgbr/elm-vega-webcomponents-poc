let
   elm019Env = fetchGit {
      url = "git@github.com:dividat/elm-compiler.git";
      ref = "master";
   };

   elm = (import elm019Env {
     dependenciesFrom = [
        # ./elm.json
        # ./tests/elm.json
     ];
   });
in
   elm.shell
