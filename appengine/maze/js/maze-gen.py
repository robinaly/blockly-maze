#!/usr/bin/env python
import random

def get(game,x,y):
  try:
    return game[y][x]
  except:
    return None

def get(game,x,y,v):
  game[y][x] = v

def randomizeGame(game):
  imgx = 8; imgy = 8
  mx = 8; my = 8 # width and height of the maze
  maze = [[0 for x in range(mx)] for y in range(my)]
  dx = [0, 1, 0, -1]; dy = [-1, 0, 1, 0] # 4 directions to move in the maze
  color = [0, 1] # RGB colors of the maze
  # start the maze from a random cell
  cx = random.randint(0, mx - 1); cy = random.randint(0, my - 1)
  maze[cy][cx] = 1; stack = [(cx, cy, 0)] # stack element: (x, y, direction)

  while len(stack) > 0:
      (cx, cy, cd) = stack[-1]
      # to prevent zigzags:
      # if changed direction in the last move then cannot change again
      if len(stack) > 2:
          if cd != stack[-2][2]: dirRange = [cd]
          else: dirRange = range(4)
      else: dirRange = range(4)

      # find a new cell to add
      nlst = [] # list of available neighbors
      for i in dirRange:
          nx = cx + dx[i]; ny = cy + dy[i]
          if nx >= 0 and nx < mx and ny >= 0 and ny < my:
              if maze[ny][nx] == 0:
                  ctr = 0 # of occupied neighbors must be 1
                  for j in range(4):
                      ex = nx + dx[j]; ey = ny + dy[j]
                      if ex >= 0 and ex < mx and ey >= 0 and ey < my:
                          if maze[ey][ex] == 1: ctr += 1
                  if ctr == 1: nlst.append(i)

      # if 1 or more neighbors available then randomly select one and move
      if len(nlst) > 0:
          ir = nlst[random.randint(0, len(nlst) - 1)]
          cx += dx[ir]; cy += dy[ir]; maze[cy][cx] = 1
          stack.append((cx, cy, ir))
      else: stack.pop()
      
  for ky in range(imgy):
      for kx in range(imgx):
          game[kx][ky] = color[maze[my * ky / imgy][mx * kx / imgx]]
  
  coords = [ (x,y) for x in range(mx) for y in range(my) if game[x][y] == 1]
  start, end = random.sample(coords, 2)
  x, y = start
  game[x][y] = 2
  x, y = end
  game[x][y] = 3
  

def main():
  games = [ [[0 for col in range(8)] for row in range(8) ]for game in range(10) ]
  for game in games:
    randomizeGame(game)
  
  print '['
  for game in games:
    for i,line in enumerate(game):
      prefix = ' '
      suffix = ''
      if i == 0:
        prefix = '['
      if i == len(game)-1:
        suffix = ']'
      print prefix + str(line) + suffix + ','
  print ']'
    
if __name__ == '__main__':
  main()