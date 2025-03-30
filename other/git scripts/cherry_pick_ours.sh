
#!/bin/bash

# Array of commit hashes to cherry-pick

COMMITS=(

  "800cefc049d582d84f61388afc45df969d0557bb"

  "6b342aaffa337d15d2a9f98a9fb9caa6beb7ca83"

  "fbd0d954c513366feb5167d1754c2a40dedb5734"

  "ceaf4aeac60b2c8296c19848135fe554665a8acb"

  "f68b02a373c6dd5ecb93b1c11a9ceaddd7f37093"

  "7f0987838c594c9cfdec0aef93f2eb171dbe8a6c"

  "63e33b978d08466345bf6c22a3f750ceb72fcb72"

  "041ce0269d9f7bc8686fe18ce2d4850c5e960bda"

  "8a8207ceb19babac2767db5e543dfdb3ffcd82ab"

  "47410c831d80ff65f38588be93526bab5c11deb4"

  "f7acd139fdb4ff54e897ab522ecb41172f808670"

  "7c6765ec5ae1306dfb536418a0bb9529e6d925f9"

  "577fd59055f4ac78a6f93218c85740a449fba824"

  "3f1116213e7d0ee3f8f6315254b5f8464a04fbaf"

  "cd64ac5dc46e63c65bfd5b5e31d095c6e15735cb"

  "2b071190094ffb44e594e12b5f61542f778f6b54"

  "aad1d9e4dc786509816980491b345b7ecaaa6422"

  "00868414bbde72110dd05de3304662f068711af0"

  "294d9e3bf4e80866ab1621f378a3a00735cab8b4"

  "dbd0a081be35767565210d101c204a728d40a1d8"

  "c6a61d5974790454872a9ce8b01b4b5047c7b7f5"

  "8de8b8fe7e742bd6eddb921fea4b8c9e29a7c15a"

  "563a4339cf476a6f99b0179be5c838a2824ad198"

  "343eadef22ee58c2bda7152e04f4e5abdcee342c"

  "5c07056a8e846c0d5bd3046a9f84f9b9344b898e"

  "6af2ac3c2c5c6821d1988cff2abb5e2d3998466c"

  "99d06752a7a173c3b01ebfd661ba31daf3b51536"

)

# Process each commit

for commit in "${COMMITS[@]}"; do

  echo "Processing commit $commit"

  

  # Try cherry-pick with ours strategy

  if ! git cherry-pick -Xours $commit; then

    echo "Conflict detected, resolving with our version"

    # If there are still conflicts, force our version

    git checkout --ours .

    git add .

    git cherry-pick --continue

  fi

  

  echo "Processed commit $commit"

done

echo "All commits processed successfully."

