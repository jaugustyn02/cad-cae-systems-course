from mazelib import Maze # type: ignore
from mazelib.generate.Prims import Prims # type: ignore
import scipy.io # type: ignore
import numpy as np
import sys

def get_knot_vectors(dimension: int, lenght: int):
    beg = [0 for _ in range(dimension)]
    mid = [i for i in range(1, lenght-1)]
    end = [lenght-1 for _ in range(dimension)]
    return beg+mid+end

def add_outer_entrances(grid: list[list[int]]):
    grid[1][0] = 0
    grid[-2][-1] = 0

def main():
    if len(sys.argv) not in (3, 4):
        print(f"[Usage]: python {sys.argv[0]} [row halls] [col halls] [optional: file name]")
        return
    
    row_halls = int(sys.argv[1])
    col_halls = int(sys.argv[2])

    file_name = "data"
    if len(sys.argv) == 4:
        file_name = sys.argv[3]

    m = Maze()
    m.generator = Prims(row_halls, col_halls) # type: ignore
    m.generate()

    add_outer_entrances(m.grid) # type: ignore

    vectorx_len = 2 * col_halls + 1
    vectory_len = 2 * row_halls + 1
    knot_vectorx = get_knot_vectors(2, vectorx_len)
    knot_vectory = get_knot_vectors(2, vectory_len)

    with open(file_name + ".txt", "w") as file:
        file.write(f"knot_vectorx = {knot_vectorx};\n\n")
        file.write(f"knot_vectory = {knot_vectory};\n\n")
        file.write(f"coeffs = {np.array2string(np.array(m.grid), separator=' ', threshold=10**10, max_line_width=10*10)};\n") # type: ignore

    knot_vectorx = np.array(knot_vectorx, dtype=np.float64)
    knot_vectory = np.array(knot_vectory, dtype=np.float64)
    coeffs = np.array(m.grid, dtype=np.float64) # type: ignore

    scipy.io.savemat(f'{file_name}.mat', {  # type: ignore
        'knot_vectorx': knot_vectorx,
        'knot_vectory': knot_vectory,
        'coeffs': coeffs})

    print(f"Maze data successfuly saved to {file_name}.txt and {file_name}.mat")

if __name__=="__main__":
    main()