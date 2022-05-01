#include <iostream>
#include <string>
#include <fstream>
#include <map>
#include <set>
#include <random>
#include <algorithm>

void get_5_letter_words(const std::string& filename)
{
	std::fstream in_file(filename);
	std::string line;
	while (std::getline(in_file, line, '\n'))
	{
		if (line.length() == 6)
			std::cout << line << '\n';
	}
}

void get_words(const std::string& filename, std::set<std::string>& words)
{
	std::fstream in_file(filename);
	std::string line;
	while (std::getline(in_file, line, '\n'))
	{
		line.erase(line.size() - 1);
		// line.erase(std::remove(line.begin(), line.end(), '\r'), line.end());
		// line.erase(std::remove(line.begin(), line.end(), '\n'), line.end());
		words.insert(line);
	}
}

bool check_if_5_letters(const std::string& user_input)
{
	for (unsigned int i = 0; i < user_input.length(); i++)
	{
		if (std::isdigit(user_input[i]))
			return false;
	}
	return (user_input.length() == 5);
}

bool check_if_in_dictionary(const std::string& user_input, std::set<std::string>& words)
{
	for (std::set<std::string>::iterator it = words.begin(); it != words.end(); it++)
	{
		// std::cout << (*it).length() << '\n';
		if (user_input.compare(*it) == 0)
			return true;
	}
	return false;
}

std::string perform_wordle(const std::string& answer, const std::string& user_input)
{
	std::map<char, int> dict;
	for (unsigned int i = 0; i < answer.length(); i++)
	{
		char a = answer[i];
		if (dict.find(a) == dict.end())
			dict.insert(std::pair<char, int>(a, 1));
		else
			dict[a]++;
	}

	char result[6];
	for (unsigned int i = 0; i < answer.length(); i++)
	{
		char a = answer[i];
		char b = user_input[i];

		if (a == b)
		{
			result[i] = '+';
		}
		else if ((dict.find(b) != dict.end()) && (dict[b] > 0))
		{
			result[i] = '*';
			dict[b]--;
		}
		else
		{
			result[i] = '-';
		}
	}
	result[5] = '\0';

	return std::string(result);
}

int main(void)
{
	// get_5_letter_words("words_alpha.txt");

	std::set<std::string> words;
	get_words("words5.txt", words);

	unsigned int t = (unsigned int)(time(NULL));
	srand(t);

	int r = (rand() % static_cast<int>(words.size() + 1));
	std::set<std::string>::iterator it = words.begin();
	std::advance(it, r - 1);
	std::string answer(*it);

	std::cout << "r: " << r << " = " << answer << '\n';

	unsigned int attempts = 0;
	while (true)
	{
		std::string user_input;
		std::cout << "Please enter guess: ";
		std::getline(std::cin, user_input, '\n');
		std::cout << user_input << " = " << user_input.length() << '\n';

		if (user_input.compare(answer) == 0)
		{
			std::cout << "Congratulations! You got it in " << attempts << " attempt(s)!\n";
			break;
		}

		bool is_length_valid = check_if_5_letters(user_input);
		bool is_in_dict = check_if_in_dictionary(user_input, words);
		if (!is_length_valid)
		{
			std::cout << "Please enter 5-letter word only.\n";
			continue;
		}
		if (!is_in_dict)
		{
			std::cout << "Word is not in dictionary. Try again.\n";
			continue;
		}

		std::string result = perform_wordle(answer, user_input);
		std::cout << result << '\n';
		attempts++;
	}

	return 0;
}
