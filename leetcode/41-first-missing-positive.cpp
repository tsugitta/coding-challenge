// https://leetcode.com/problems/first-missing-positive/
#include <iostream>
#include <vector>

using namespace std;

class Solution
{
  public:
    int firstMissingPositive(vector<int> &nums)
    {
        int n = nums.size();

        for (int i = 0; i < n; i++)
        {
            int value = nums[i];
            while (value >= 1 &&
                   value <= n &&
                   nums[value - 1] != value)
            {
                swap(nums[value - 1], value);
            }
        }

        for (int i = 0; i < n; i++)
        {
            if (nums[i] != i + 1)
            {
                return i + 1;
            }
        }

        return n + 1;
    }
};
