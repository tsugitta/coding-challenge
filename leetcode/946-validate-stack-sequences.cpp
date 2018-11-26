#include <iostream>
#include <vector>

using namespace std;

class Solution
{
  public:
    bool validateStackSequences(vector<int> &pushed, vector<int> &popped)
    {
        vector<int> stack{};
        int toBePoppedNextIndex = 0;

        for (int x : pushed)
        {
            stack.push_back(x);

            while (stack.size() > 0 && stack.back() == popped[toBePoppedNextIndex])
            {
                toBePoppedNextIndex++;
                stack.pop_back();
            }
        }

        return toBePoppedNextIndex == popped.size();
    }
};
