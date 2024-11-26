import numpy as np

class Tree:
    def __init__(self, tree_index):
        self.tree_index = tree_index
        self.x_coord = 0
        self.y_coord = 0

        self.crown_base = 0
        self.crown_d1 = 0
        self.crown_d2 = 0
        self.crown_d3 = 0
        self.crown_base_height = 0
        self.crown_center_height = 0
        self.tree_height = 0
        self.crown_volume = 0
        self.single_leaf_area = 0
        self.total_leaf_area = 0
        self.total_tree_branch_area = 0
        self.total_tree_stem_area = 0
        self.total_tree_ground_area = 0
        self.total_tree_canopy_veg_area = 0

    def __str__(self):
        return f"Tree {self.tree_index}: {self.__dict__}"

    def print_attributes(self):
        for key, value in self.__dict__.items():
            print(f"{key}: {value}")

class Circle:
    def __init__(self, circle_name):
        self.circle_name = circle_name
        self.x_coord = 0
        self.y_coord = 0
        self.row = 0
        self.column = 0

        # Initialize attributes with NumPy arrays
        self.tree_indices = np.array([], dtype=int)
        self.crown_vol_in_circle = np.array([], dtype=float)
        self.crown_percentages = np.array([], dtype=float)
        self.tree_heights = np.array([], dtype=float)
        self.single_leaf_areas = np.array([], dtype=float)
        self.adj_branch_areas = np.array([], dtype=float)
        self.adj_leaf_areas = np.array([], dtype=float)
        self.total_tree_canopy_veg_area = np.array([], dtype=float)

        # self.leaf_area_per_meter_range = np.array([], dtype=float)
        # self.veg_area_per_meter_range = np.array([], dtype=float)
        # self.total_leaf_area_per_meter_range = np.array([], dtype=float)
        # self.total_veg_area_per_meter_range = np.array([], dtype=float)

        self.Fa_leaf_branch_per_tree = np.array([], dtype=float)
        self.Fa_array = np.array([], dtype=float)
        self.Fa_b_array = np.array([], dtype=float)
        self.total_Fa = np.array([], dtype=float)
        self.total_Fa_b = np.array([], dtype=float)
        self.Li_dz_leaf = np.array([], dtype=float)
        self.Li_dz_branch = np.array([], dtype=float)
        self.tree_height_array = np.array([], dtype=float)
        self.total_Li_dz_leaf = np.array([], dtype=float)
        self.total_Li_dz_branch = np.array([], dtype=float)
        
        self.height_groups = np.array([], dtype=int)
        self.trees_by_height_group = np.array([], dtype=int)

        # self.Fa_per_range = np.array([], dtype=float)
        # self.Fa_b_per_range = np.array([], dtype=float)
        # self.F_act = np.array([], dtype=float)
        # self.F_act_b = np.array([], dtype=float)
        # self.F_act_without_pi = np.array([], dtype=float)
        # self.F_act_b_without_pi = np.array([], dtype=float)
        # self.total_F_act = np.array([], dtype=float)
        # self.total_F_act_b = np.array([], dtype=float)

        # Initialize other attributes with scalar values
        self.tree_density = 0
        self.tree_percent_total = 0
        self.mean_crown_d1 = 0
        self.std_crown_d1 = 0
        self.mean_crown_d2 = 0
        self.std_crown_d2 = 0
        self.mean_crown_center_height = 0
        self.std_crown_center_height = 0
        self.mean_tree_height = 0
        self.std_tree_height = 0
        self.total_leaf_veg_area = 0
        self.mean_crown_volume = 0
        self.std_crown_volume = 0
        self.total_crown_volume = 0
        self.adj_crown_volume = 0
        self.pixel_area = 0
        self.total_vegetation_area_per_pixel = 0
        self.LAI_with_branch = 0
        self.LAI_without_branch = 0
        self.h1 = 0
        self.h2 = 0
        self.Fa = 0
        self.Fa_b = 0

        self.new_Fa = 0

    def __str__(self):
        return f"Circle {self.circle_name}: {self.__dict__}"

    def print_attributes(self):
        for key, value in self.__dict__.items():
            # Check if the value is a numpy array
            if isinstance(value, np.ndarray):
                # Print numpy array without scientific notation
                np.set_printoptions(suppress=True)  # Suppress scientific notation for numpy arrays
                print(f"{key}: {value}")
            else:
                # For other attributes (non-numpy arrays), format as float without scientific notation
                if isinstance(value, float):
                    print(f"{key}: {value:.6f}")  # Adjust precision (6 decimal places in this example)
                else:
                    print(f"{key}: {value}")
                    
    def group_trees_by_height(self, tree_list, cutoffs):
        # Sort cutoffs and add -inf and inf for open-ended ranges
        cutoffs_sorted  = sorted(cutoffs)
        cutoffs = [-np.inf] + cutoffs_sorted + [np.inf]
        self.height_groups = cutoffs_sorted

        # Initialize trees_by_height_group to store tree indices for each height group
        self.trees_by_height_group = [[] for _ in range(len(cutoffs) - 1)]
        self.crown_percentages_by_group = [[] for _ in range(len(cutoffs) - 1)]
        self.crown_vol_by_group = [[] for _ in range(len(cutoffs) - 1)]

        # Debug: Print the entire tree_indices list before processing
        print(f"Processing circle {self.circle_name} with tree indices: {self.tree_indices}")

        # Filter trees into height groups
        for tree_index, crown_percentage, crown_vol in zip(self.tree_indices, self.crown_percentages, self.crown_vol_in_circle):
            tree = next((t for t in tree_list if t.tree_index == tree_index), None)
            
            if tree is None:
                print(f"Warning: Tree with index {tree_index} not found in tree_list.")
                continue  # Skip if the tree is not found

            # Debug: Print the current tree index being processed and its height
            # print(f"Processing tree index {tree.tree_index} with height {tree.tree_height}")

            # Place tree index in the appropriate height group
            for i in range(len(cutoffs) - 1):
                if cutoffs[i] <= tree.tree_height < cutoffs[i + 1]:
                    self.trees_by_height_group[i].append(tree.tree_index)
                    self.crown_percentages_by_group[i].append(crown_percentage)
                    self.crown_vol_by_group[i].append(crown_vol)
                    # Debug: Print which group the tree is placed in
                    # print(f"Tree index {tree.tree_index} placed in group {i} (Height range: {cutoffs[i]} - {cutoffs[i+1]})")
                    break
        # Debug: Print the final groupings
        print(f"Height groupings for {self.circle_name}: {self.height_groups}")
        print(f"Trees by height group: {self.circle_name}: {self.trees_by_height_group}")
        print(f"Crown percentages by height group for {self.circle_name}: {self.crown_percentages_by_group}")
        print(f"Crown volumes by height group for {self.circle_name}: {self.crown_vol_by_group}")

class Circle_pgap:
    def __init__(self, circle_name):
        self.circle_name = circle_name
        self.row = 0
        self.column = 0

        self.height_z = np.array([], dtype=int)
        self.Fa = np.array([], dtype=int)
        self.accFa = np.array([], dtype=int)
        self.p = np.array([], dtype=int)

    def __str__(self):
        return f"Circle {self.circle_name}: {self.__dict__}"

    def print_attributes(self):
        for key, value in self.__dict__.items():
            # Check if the value is a numpy array
            if isinstance(value, np.ndarray):
                # Print numpy array without scientific notation
                np.set_printoptions(suppress=True)  # Suppress scientific notation for numpy arrays
                print(f"{key}: {value}")
            else:
                # For other attributes (non-numpy arrays), format as float without scientific notation
                if isinstance(value, float):
                    print(f"{key}: {value:.6f}")  # Adjust precision (6 decimal places in this example)
                else:
                    print(f"{key}: {value}")