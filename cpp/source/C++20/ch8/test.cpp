#include "Person.h"
#include <iostream>
#include <memory>  // For std::make_unique
#include <sstream> // For std::ostringstream

using namespace std;

int main()
{
    // On the stack:
    Person person1{ "John", "Doe" };
    ostringstream oss1;
    oss1 << person1.getFirstName() << " " << person1.getLastName();
    cout << oss1.str() << endl;

    // On the free store:
    auto person2 = make_unique<Person>("Marc", "Gregoire");
    ostringstream oss2;
    oss2 << person2->getFirstName() << " " << person2->getLastName();
    cout << oss2.str() << endl;
}