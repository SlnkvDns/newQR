#include "variantdistributor.h"
#include <vector>
#include <map>
#include <tuple>
#include <algorithm>
#include <unordered_set>
#include <random>

VariantDistributor::VariantDistributor(QObject *parent) : QObject(parent) {}

static std::tuple<int, int> parseStringToTuple(const std::string& str) {
    int firstNumber = 0, secondNumber = 0;
    size_t i = 0;
    while (i < str.size() && !isdigit(str[i])) ++i;
    while (i < str.size() && isdigit(str[i]))
        firstNumber = firstNumber * 10 + (str[i++] - '0');
    while (i < str.size() && !isdigit(str[i])) ++i;
    while (i < str.size() && isdigit(str[i]))
        secondNumber = secondNumber * 10 + (str[i++] - '0');
    return {firstNumber, secondNumber};
}

static std::string makeKey(int row, int seat) {
    return "р" + std::to_string(row) + "м" + std::to_string(seat);
}

static std::map<std::string, int> createDictionary(const std::vector<std::string>& arr, int variants) {
    std::random_device rd;
    std::mt19937 gen(rd());
    std::map<std::string, int> dictionary;
    std::vector<std::tuple<int, int>> tupleList;
    std::unordered_set<std::string> seatExists;
    std::map<std::string, std::tuple<int, int>> seatToTuple;

    // Парсинг входных данных
    for (const std::string& input : arr) {
        auto parsedTuple = parseStringToTuple(input);
        int row = std::get<0>(parsedTuple);
        int seat = std::get<1>(parsedTuple);
        std::string key = makeKey(row, seat);

        tupleList.push_back(parsedTuple);
        seatExists.insert(key);
        seatToTuple[key] = parsedTuple;
    }

    // Построение графа соседства
    std::map<std::string, std::vector<std::string>> graph;

    for (const auto& item : tupleList) {
        int row = std::get<0>(item);
        int seat = std::get<1>(item);
        std::string currentKey = makeKey(row, seat);

        // Проверка соседей (4 направления)
        const int directions[4][2] = {{-1,0}, {1,0}, {0,-1}, {0,1}};
        for (const auto& dir : directions) {
            int newRow = row + dir[0];
            int newSeat = seat + dir[1];
            int steps = 0;

            while (steps++ < 25) {
                std::string key = makeKey(newRow, newSeat);
                if (seatExists.count(key)) {
                    graph[currentKey].push_back(key);
                    break;
                }
                newRow += dir[0];
                newSeat += dir[1];
            }
        }
    }

    std::vector<std::string> allSeats;
    for (const auto& item : seatToTuple)
        allSeats.push_back(item.first);

    if (variants >= static_cast<int>(seatToTuple.size())) {
        // Случай 1: вариантов больше или равно числу студентов
        std::shuffle(allSeats.begin(), allSeats.end(), gen);

        int variant = 1;
        for (const auto& key : allSeats)
            dictionary[key] = variant++;
    } else {
        // Случай 2: вариантов меньше, чем студентов
        std::shuffle(allSeats.begin(), allSeats.end(), gen);
        std::vector<int> usage(variants + 1, 0);

        for (const auto& key : allSeats) {
            std::vector<bool> used(variants + 1, false);

            // Проверяем соседей
            for (const auto& neighbor : graph[key]) {
                int color = dictionary[neighbor];
                if (color > 0 && color <= variants)
                    used[color] = true;
            }

            // Выбираем подходящий вариант
            std::vector<int> candidates;
            for (int c = 1; c <= variants; ++c) {
                if (!used[c]) candidates.push_back(c);
            }

            int chosenColor;
            if (candidates.empty()) {
                chosenColor = std::uniform_int_distribution<>(1, variants)(gen);
            } else {
                chosenColor = candidates[0];
                for (int c : candidates) {
                    if (usage[c] < usage[chosenColor])
                        chosenColor = c;
                }
            }

            dictionary[key] = chosenColor;
            usage[chosenColor]++;
        }
    }

    return dictionary;
}

QVariantMap VariantDistributor::distributeVariants(const QStringList &positions, int variantsCount)
{
    std::vector<std::string> inputs;
    for (const QString &qStr : positions)
        inputs.push_back(qStr.toStdString());

    auto result = createDictionary(inputs, variantsCount);

    QVariantMap output;
    for (const auto &pair : result)
        output[QString::fromStdString(pair.first)] = pair.second;

    return output;
}
