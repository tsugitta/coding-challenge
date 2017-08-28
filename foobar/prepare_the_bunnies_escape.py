"""
Prepare the Bunnies' Escape
===========================

You're awfully close to destroying the LAMBCHOP doomsday device and freeing Commander Lambda's bunny prisoners, but once they're free of the prison blocks, the bunnies are going to need to escape Lambda's space station via the escape pods as quickly as possible. Unfortunately, the halls of the space station are a maze of corridors and dead ends that will be a deathtrap for the escaping bunnies. Fortunately, Commander Lambda has put you in charge of a remodeling project that will give you the opportunity to make things a little easier for the bunnies. Unfortunately (again), you can't just remove all obstacles between the bunnies and the escape pods - at most you can remove one wall per escape pod path, both to maintain structural integrity of the station and to avoid arousing Commander Lambda's suspicions. 

You have maps of parts of the space station, each starting at a prison exit and ending at the door to an escape pod. The map is represented as a matrix of 0s and 1s, where 0s are passable space and 1s are impassable walls. The door out of the prison is at the top left (0,0) and the door into an escape pod is at the bottom right (w-1,h-1). 

Write a function answer(map) that generates the length of the shortest path from the prison door to the escape pod, where you are allowed to remove one wall as part of your remodeling plans. The path length is the total number of nodes you pass through, counting both the entrance and exit nodes. The starting and ending positions are always passable (0). The map will always be solvable, though you may or may not need to remove a wall. The height and width of the map can be from 2 to 20. Moves can only be made in cardinal directions; no diagonal moves are allowed.

Languages
=========

To provide a Python solution, edit solution.py
To provide a Java solution, edit solution.java

Test cases
==========

Inputs:
    (int) maze = [[0, 1, 1, 0], [0, 0, 0, 1], [1, 1, 0, 0], [1, 1, 1, 0]]
Output:
    (int) 7

Inputs:
    (int) maze = [[0, 0, 0, 0, 0, 0], [1, 1, 1, 1, 1, 0], [0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1], [0, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0]]
Output:
    (int) 11

Use verify [file] to test your solution and see how it does. When you are finished editing your code, use submit [file] to submit your answer. If your solution passes the test cases, it will be removed from your home folder.
"""

PATH = 0
WALL = 1
NON_REACHABLE = -1

class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        
    def __eq__(self, other):
        if isinstance(other, self.__class__):
            return self.x == other.x and self.y == other.y
        return False
        
class Solver:
    def __init__(self, maze):
        self.maze = maze
        self.w = len(maze[0])
        self.h = len(maze)
        self.start = Point(0, 0)
        self.goal = Point(self.h-1, self.w-1)
    
    def solve(self):
        res = float('infinity')
        
        cost_matrix_for_start = self.cost_matrix_from_point(self.start)
        cost_matrix_for_goal = self.cost_matrix_from_point(self.goal)
        
        cost_for_non_removing_wall = cost_matrix_for_start[self.goal.x][self.goal.y]
        if cost_for_non_removing_wall != NON_REACHABLE:
            res = cost_for_non_removing_wall
        
        paths_from_start = self.cost_matrix_to_paths(cost_matrix_for_start)
        paths_from_goal = self.cost_matrix_to_paths(cost_matrix_for_goal)
        
        adjacent_walls_for_start = self.walls_included_in(self.adjacents_for_points(paths_from_start))
        adjacent_walls_for_goal = self.walls_included_in(self.adjacents_for_points(paths_from_goal))
        
        common_adjacent_walls = self.common_points(adjacent_walls_for_start, adjacent_walls_for_goal)
        for wall in common_adjacent_walls:
            _c = self.cost_when_removing_wall(wall, cost_matrix_for_start, cost_matrix_for_goal)
            if _c < res:
                res = _c
        
        return res
        
    # cost matrix: a matrix whose cells represent the required step count from the point (from 1).
    # non-reachable point has -1 (NON_REACHABLE)
    def cost_matrix_from_point(self, p):
        c_mat = [[NON_REACHABLE] * self.w for _i in range(0, self.h)]
        c_mat[p.x][p.y] = 1
        self.update_cost_matrix_from_point(p, c_mat)
        return c_mat
    
    def update_cost_matrix_from_point(self, p, c_mat):
        p_cost = c_mat[p.x][p.y]
        
        for rp in self.paths_included_in(self.adjacents_of_point(p)):
            if self.maze[rp.x][rp.y] == PATH and \
                (c_mat[rp.x][rp.y] == NON_REACHABLE or c_mat[rp.x][rp.y] > p_cost + 1):
                    c_mat[rp.x][rp.y] = p_cost + 1
                    self.update_cost_matrix_from_point(rp, c_mat)

    def cost_matrix_to_paths(self, cost_matrix):
        res = []
        
        for x in range(0, self.h):
            for y in range(0, self.w):
                if cost_matrix[x][y] != NON_REACHABLE:
                    res.append(Point(x, y))
                    
        return res
                
    def cost_when_removing_wall(self, wall, start_cost_matrix, goal_cost_matrix):
        min_cost_for_start_adjacent = float('inf')
        min_cost_for_goal_adjacent =float('inf')
        
        for p in self.adjacents_of_point(wall):
            cost_for_start = start_cost_matrix[p.x][p.y]            
            if cost_for_start != NON_REACHABLE and cost_for_start < min_cost_for_start_adjacent:
                min_cost_for_start_adjacent = cost_for_start
            
            cost_for_goal = goal_cost_matrix[p.x][p.y]
            if cost_for_goal != NON_REACHABLE and cost_for_goal < min_cost_for_goal_adjacent:
                min_cost_for_goal_adjacent = cost_for_goal

        return min_cost_for_start_adjacent + min_cost_for_goal_adjacent + 1 # 1 means step of path appeared after removing wall
        
    def adjacents_for_points(self, ps):
        res = []
        
        for p in ps:
            for point in self.adjacents_of_point(p):
                if point not in res:
                    res.append(point)
                    
        return list(res)
    
    def walls_included_in(self, points):
        return [p for p in points if self.maze[p.x][p.y] == WALL]

    def paths_included_in(self, points):
        return [p for p in points if self.maze[p.x][p.y] == PATH]
    
    def adjacents_of_point(self, p):
        candidates = [
            Point(p.x, p.y - 1),
            Point(p.x, p.y + 1),
            Point(p.x - 1, p.y),
            Point(p.x + 1, p.y),
        ]
        
        return [c for c in candidates if self.maze_includes(c)]

    def common_points(self, ps1, ps2):
        return filter(lambda p: p in ps2, ps1)
    
    def maze_includes(self, p):
        return p.x in range(0, self.h) and p.y in range(0, self.w)
    
maze_1 = [[0, 1, 1, 0], [0, 1, 0, 1], [1, 1, 0, 0], [1, 1, 1, 0]]
maze_2 = [[0, 0, 0, 0, 0, 0], [1, 1, 1, 1, 1, 0], [0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1], [0, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0]]
            
s = Solver(maze_1)
s.solve()
