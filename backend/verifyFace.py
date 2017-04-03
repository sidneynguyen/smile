#!/usr/bin/local/python

import os
import sys
import cognitive_face as CF

imageId = sys.argv[1]

KEY = 'a154bd9a80564b6da75920a78c537d59'
CF.Key.set(KEY)

img_url = './smiles/' + imageId + '.jpg'
result = CF.face.detect(img_url, True, False, 'smile')
numSmiles = 0
for face in result:
  if face['faceAttributes']['smile'] > 0.3:
    numSmiles += 1
if numSmiles < 2:
  os.remove(img_url)
print(numSmiles)